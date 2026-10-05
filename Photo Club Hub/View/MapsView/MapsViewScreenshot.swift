//
//  MapsViewScreenshot.swift
//  Photo Club Hub
//
//  Created by Claude Code guided by Peter van den Hamer on 04/10/2026.
//

import SwiftUI // for View
import MapKit // for MKMapSnapshotter
import CoreData // for FetchedResults and NSManagedObjectID
import Photo_Club_Hub_Data // for types like Organization

/// An image of an organization's locked map (#867), to show instead of a live MapKit map.
///
/// Live maps load tiles and keep a MapKit view alive, so a fast scroll past many cards cost lots of memory (#804).
/// A locked map cannot pan or zoom anyway, so a static image of its default view looks the same at a fraction of
/// the memory usage. `MKMapSnapshotter` makes the image at the card's exact size, in its light or dark appearance.
///
/// The markers are not included the static image: they are SwiftUI views drawn on top of it,
/// at the points where the screenshot says their coordinates landed.
/// That keeps their colors current when the highlight settings change, and lets a later
/// tap on a pin be handled like any SwiftUI tap (#256).
///
/// The user's location is deliberarly left out of the static image. It is a blue dot (or a larger circle with the
/// approximate location), and iOS updates it when needed. Showing it would make an image stale whenever the user moves.
/// Unlocking a map replaces the static image by a live map, and the live map shows the user's location again.
@MainActor
struct MapsViewScreenshot: View {

    @ObservedObject var mapOrganization: Organization      // the organization this image is centered on
    var fetchedOrganizations: FetchedResults<Organization> // all organizations; the nearby ones get a marker

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    @State private var size: CGSize = .zero // the size this view got from layout
    @State private var screenshot: MapScreenshot? // nil until the first image is ready

    var body: some View {
        // Takes the same space as `MapsViewMap`, so a card keeps its height when switching between the two.
        Color.clear
            .frame(minHeight: MapsViewMap.minHeight, idealHeight: MapsViewMap.idealHeight, maxHeight: .infinity)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                size = newSize
            }
            .overlay {
                if let screenshot {
                    // After a size change, the old image is stretched for a moment until the new one is ready.
                    Image(uiImage: screenshot.image)
                        .resizable()
                    markers(on: screenshot)
                }
            }
            .clipped() // a marker near the edge must not draw over the card's title or remark
            // Cancelled by SwiftUI when the view disappears, which also cancels the screenshotter.
            .task(id: ScreenshotRequest(size: size, colorScheme: colorScheme, displayScale: displayScale)) {
                guard size.width > 0, size.height > 0 else { return } // layout hasn't happened yet
                let markerCoordinates = Dictionary(uniqueKeysWithValues: nearbyOrganizations.map { nearby in
                    (nearby.objectID, nearby.coordinates)
                })
                do {
                    let newScreenshot = try await Self.makeScreenshot(
                        region: MapsViewMap.defaultRegion(of: mapOrganization),
                        size: size,
                        colorScheme: colorScheme,
                        displayScale: displayScale,
                        markerCoordinates: markerCoordinates)
                    withAnimation(.easeIn(duration: MapsViewCard.fadeInSeconds)) { screenshot = newScreenshot }
                } catch {
                    // Cancelled, or MapKit failed (e.g. offline with no cached tiles). Either way, nothing to show.
                    // A failure is retried when the view appears again.
                }
            }
    }

    /// The organizations that get a marker: the same ones as on a locked live map.
    private var nearbyOrganizations: [Organization] {
        MapsViewMap.nearbyOrganizations(around: mapOrganization, fetchedOrganizations: fetchedOrganizations)
    }

    /// A marker for each nearby organization, at the point where the screenshot placed its coordinates.
    /// Where markers overlap, the card's own organization is always on top. Among the others, the southern one is on
    /// top, as MapKit does on a live map. The markers are simply drawn in that order: later is on top.
    private func markers(on screenshot: MapScreenshot) -> some View {
        let labeled = labeledOrganizations(screenshot: screenshot)
        let placed = nearbyOrganizations
            .compactMap { nearby in screenshot.markerPoints[nearby.objectID].map { (organization: nearby, point: $0) } }
            .sorted { first, second in
                if isMapOrganization(first.organization) != isMapOrganization(second.organization) {
                    return isMapOrganization(second.organization)
                }
                return first.organization.latitude_ > second.organization.latitude_ // north first, so south on top
            }
        return ForEach(placed, id: \.organization.objectID) { marker in
            let hasLabel = labeled.contains(marker.organization.objectID)
            MapsViewScreenshotMarker(title: hasLabel ? marker.organization.fullName : nil,
                                   organization: marker.organization,
                                   mapOrganization: mapOrganization)
            .position(marker.point)
            .offset(y: -MapsViewScreenshotMarker.balloonHeight / 2) // puts the balloon's tip on the point
        }
    }

    /// Whether `candidate` is this card's own organization, the one with the purple marker.
    private func isMapOrganization(_ candidate: Organization) -> Bool {
        MapsViewMap.isMapOrganization(candidate, mapOrganization: mapOrganization)
    }

    /// The organizations whose marker gets a name below it.
    ///
    /// A live map hides a label that would overlap another label or a marker, so a crowded area (Eindhoven) stays
    /// readable. This does roughly the same: it places the labels one by one, the card's own organization first and
    /// then by distance from it, and skips any label that would overlap a label placed earlier or any other marker.
    /// The card's own organization is always labeled, even over a neighbor's marker: the live map does the same,
    /// because its own marker is kept selected (see `MapsViewMap.mapMarkerTagString`).
    private func labeledOrganizations(screenshot: MapScreenshot) -> Set<NSManagedObjectID> {
        let center = CLLocation(latitude: mapOrganization.latitude_, longitude: mapOrganization.longitude_)
        let candidates = nearbyOrganizations
            .filter { screenshot.markerPoints[$0.objectID] != nil }
            .sorted { first, second in
                if isMapOrganization(first) { return true }
                if isMapOrganization(second) { return false }
                let firstLocation = CLLocation(latitude: first.latitude_, longitude: first.longitude_)
                let secondLocation = CLLocation(latitude: second.latitude_, longitude: second.longitude_)
                return firstLocation.distance(from: center) < secondLocation.distance(from: center)
            }
        let balloons = candidates.compactMap { candidate -> (NSManagedObjectID, CGRect)? in
            guard let point = screenshot.markerPoints[candidate.objectID] else { return nil }
            return (candidate.objectID, MapsViewScreenshotMarker.balloonRect(at: point))
        }

        var labeled = Set<NSManagedObjectID>()
        var placedLabels: [CGRect] = []
        for candidate in candidates {
            guard let point = screenshot.markerPoints[candidate.objectID] else { continue }
            let label = MapsViewScreenshotMarker.labelRect(for: candidate.fullName, at: point)
            let hitsLabel = placedLabels.contains { $0.intersects(label) }
            let hitsBalloon = balloons.contains { objectID, balloon in
                objectID != candidate.objectID && balloon.intersects(label)
            }
            guard isMapOrganization(candidate) || (!hitsLabel && !hitsBalloon) else { continue }
            labeled.insert(candidate.objectID)
            placedLabels.append(label)
        }
        return labeled
    }

    /// Makes the image of `region` at `size`, and finds where each of `markerCoordinates` lands on it.
    private static func makeScreenshot(region: MKCoordinateRegion,
                                       size: CGSize,
                                       colorScheme: ColorScheme,
                                       displayScale: CGFloat,
                                       markerCoordinates: [NSManagedObjectID: CLLocationCoordinate2D])
    async throws -> MapScreenshot {
        let options = MKMapSnapshotter.Options()
        options.region = region // like the live map, MapKit fits this region into the shorter side of `size`
        options.size = size
        options.preferredConfiguration = MKStandardMapConfiguration() // the style a live `Map` uses by default
        options.traitCollection = UITraitCollection { traits in
            traits.userInterfaceStyle = (colorScheme == .dark) ? .dark : .light
            traits.displayScale = displayScale // sharp on the device's screen, and no more pixels than that
        }

        let snapshotter = MKMapSnapshotter(options: options)
        let screenshot = try await withTaskCancellationHandler {
            try await snapshotter.start()
        } onCancel: {
            snapshotter.cancel()
        }
        return MapScreenshot(image: screenshot.image,
                             markerPoints: markerCoordinates.mapValues { screenshot.point(for: $0) })
    }
}

/// A finished image of a locked map, with the positions of its markers in the image's coordinates (points).
struct MapScreenshot {
    let image: UIImage
    let markerPoints: [NSManagedObjectID: CGPoint] // keyed by organization
}

/// Everything a screenshot depends on besides the organization itself. A change to any of these needs a new image.
private struct ScreenshotRequest: Equatable {
    let size: CGSize
    let colorScheme: ColorScheme
    let displayScale: CGFloat
}

/// A marker drawn on top of a map image: the same balloon as on a live map, with the organization's name below it.
/// On a live map MapKit draws the name; on an image this view does.
private struct MapsViewScreenshotMarker: View {

    let title: String? // nil when the label would overlap another label or marker
    let organization: Organization // the organization this marker is for
    let mapOrganization: Organization // the organization the map is centered on

    static let balloonHeight = MapMarkerBalloon.height

    private static let labelFont = UIFont.systemFont(ofSize: 10, weight: .semibold) // fixed, like MapKit's labels
    private static let labelMaxWidth: CGFloat = 90 // wraps about where MapKit's own label does
    private static let labelMaxLines = 2
    private static let labelGap: CGFloat = 1 // between the balloon's tip and the label

    /// Where the balloon of a marker whose tip is at `tip` is drawn, in the image's coordinates.
    static func balloonRect(at tip: CGPoint) -> CGRect {
        let width = MapMarkerBalloon.width
        return CGRect(x: tip.x - width / 2, y: tip.y - balloonHeight, width: width, height: balloonHeight)
    }

    /// Where the label `title` of a marker whose tip is at `tip` is drawn, in the image's coordinates.
    /// Measured with the same font, width and line limit as the label itself, so overlaps can be found before drawing.
    static func labelRect(for title: String, at tip: CGPoint) -> CGRect {
        let maxHeight = labelFont.lineHeight * CGFloat(labelMaxLines)
        let size = (title as NSString).boundingRect(with: CGSize(width: labelMaxWidth, height: maxHeight),
                                                    options: [.usesLineFragmentOrigin],
                                                    attributes: [.font: labelFont],
                                                    context: nil).size
        return CGRect(x: tip.x - size.width / 2, y: tip.y + labelGap,
                      width: ceil(size.width), height: min(ceil(size.height), maxHeight))
    }

    var body: some View {
        MapMarkerBalloon(organization: organization, mapOrganization: mapOrganization)
            .overlay(alignment: .top) {
                // An overlay doesn't take part in layout, so the balloon's tip stays where it was positioned.
                if let title {
                    Text(verbatim: title)
                        .font(Font(Self.labelFont))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(.label).opacity(0.75)) // MapKit's labels are dark grey, not black
                        .lineLimit(Self.labelMaxLines)
                        .frame(width: Self.labelMaxWidth)
                        .shadow(color: Color(.systemBackground), radius: 1) // a halo, like MapKit's own labels
                        .shadow(color: Color(.systemBackground), radius: 1) // twice, for a denser halo
                        .offset(y: Self.balloonHeight + Self.labelGap)
                }
            }
    }
}

// MARK: - Previews

// Believe it or not, these previews actually work

/// The static image (top) above a live map of the same data, to allow comparison.
/// Note that the two are close enough that you can't tell which is which without a direct comparison.
/// The live map is unlocked, so it can be panned and zoomed to show that it is the live one.
/// Unlocked, it also shows MapKit's controls (scale, compass when rotated, user location button).
/// Uses Fotogroep de Gender and its four neighbors (see `MapsViewMapPreviews.seedOrganization`).
@MainActor
private struct MapsViewScreenshotPreviewHost: View {

    let organization: Organization

    @FetchRequest(sortDescriptors: [SortDescriptor(\Organization.fullName_, order: .forward)])
    private var fetchedOrganizations: FetchedResults<Organization>

    init() {
        organization = MapsViewMapPreviews.seedOrganization(
            context: MapsViewMapPreviews.persistenceController.container.viewContext)
    }

    var body: some View {
        VStack {
            Text(verbatim: "Static image (MapsViewScreenshot)")
            MapsViewScreenshot(mapOrganization: organization, fetchedOrganizations: fetchedOrganizations)
                .frame(height: MapsViewMap.minHeight)
                .padding([.bottom], 20)

            Text(verbatim: "Unlocked live map (MapsViewMap)")
            MapsViewMap(mapOrganization: organization,
                        fetchedOrganizations: fetchedOrganizations,
                        isMapScrollLocked: false)
                .frame(height: MapsViewMap.minHeight)
        }
    }
}

#Preview {
    MapsViewScreenshotPreviewHost()
        .padding()
        .environment(\.managedObjectContext, MapsViewMapPreviews.persistenceController.container.viewContext)
}
