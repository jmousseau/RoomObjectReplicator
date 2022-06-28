//
//  RoomObjectSystem.swift
//  RoomObjectReplicator
//
//  Created by Jack Mousseau on 6/6/22.
//

import ARKit
import RealityFoundation
import RoomPlan

public struct RoomObjectComponent: Component {

    public var dimensions: simd_float3 = .zero
    public var category: CapturedRoom.Object.Category? = nil

}

public protocol HasRoomObjectComponent {

    var roomObject: RoomObjectComponent? { get set }

}

public class RoomObjectEntity: Entity, HasAnchoring, HasModel, HasRoomObjectComponent {

    public var anchoring: AnchoringComponent? {
        get { components[AnchoringComponent.self] }
        set { components[AnchoringComponent.self] = newValue }
    }

    public var model: ModelComponent? {
        get { components[ModelComponent.self] }
        set { components[ModelComponent.self] = newValue }
    }

    public var roomObject: RoomObjectComponent? {
        get { components[RoomObjectComponent.self] }
        set { components[RoomObjectComponent.self] = newValue }
    }

    public required convenience init() {
        self.init(dimensions: .zero)
    }

    public convenience init(_ anchor: RoomObjectAnchor) {
        self.init(dimensions: anchor.dimensions, category: anchor.category)
        components.set([AnchoringComponent(anchor)])
    }

    public init(dimensions: simd_float3, category: CapturedRoom.Object.Category? = nil) {
        super.init()

        let mesh = MeshResource.generateBox(size: .one, cornerRadius: .zero)
        let material = SimpleMaterial(color: .systemYellow, roughness: 0.27, isMetallic: false)
        let model = ModelComponent(mesh: mesh, materials: [material])
        let roomObject = RoomObjectComponent(dimensions: dimensions, category: category)
        components.set([model, roomObject])
    }

    fileprivate func update(_ anchor: RoomObjectAnchor) {
        roomObject?.dimensions = anchor.dimensions
        roomObject?.category = anchor.category
    }

}

public extension Scene {

    func addRoomObjectEntities(for anchors: [ARAnchor]) {
        addRoomObjectEntities(for: anchors.compactMap({ anchor in
            anchor as? RoomObjectAnchor
        }))
    }

    func updateRoomObjectEntities(for anchors: [ARAnchor]) {
        updateRoomObjectEntities(for: anchors.compactMap({ anchor in
            anchor as? RoomObjectAnchor
        }))
    }

    func addRoomObjectEntities(for roomObjectAnchors: [RoomObjectAnchor]) {
        for roomObjectAnchor in roomObjectAnchors {
            addAnchor(RoomObjectEntity(roomObjectAnchor))
        }
    }

    func updateRoomObjectEntities(for roomObjectAnchors: [RoomObjectAnchor]) {
        var roomObjectAnchorsByIdentifier = [UUID: RoomObjectAnchor]()
        for roomObjectAnchor in roomObjectAnchors {
            roomObjectAnchorsByIdentifier[roomObjectAnchor.identifier] = roomObjectAnchor
        }

        for anchor in self.anchors {
            guard case .anchor(let identifier) = anchor.anchoring.target else { continue }
            guard let entity = anchor as? RoomObjectEntity else { continue }
            guard let roomObjectAnchor = roomObjectAnchorsByIdentifier[identifier] else { continue }
            entity.update(roomObjectAnchor)
        }
    }

}

public class RoomObjectSystem: System {

    private let roomObjectAnchorQuery: EntityQuery

    public required init(scene: Scene) {
        roomObjectAnchorQuery = EntityQuery(where: .has(RoomObjectComponent.self) && .has(ModelComponent.self))
    }

    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(roomObjectAnchorQuery).forEach { entity in
            guard let entity = entity as? Entity & HasModel & HasRoomObjectComponent else { return }
            guard let roomObject = entity.roomObject else { return }
            entity.scale = roomObject.dimensions
            entity.model?.materials = [material(for: roomObject.category)]
        }
    }

    private func material(for category: CapturedRoom.Object.Category?) -> SimpleMaterial {
        let roughness = MaterialScalarParameter(floatLiteral: 0.27)
        guard let category = category else {
            return SimpleMaterial(color: .white, roughness: roughness, isMetallic: false)
        }

        switch category {
        case .storage: return SimpleMaterial(color: .systemGreen, roughness: roughness, isMetallic: false)
        case .refrigerator: return SimpleMaterial(color: .systemBlue, roughness: roughness, isMetallic: false)
        case .stove: return SimpleMaterial(color: .systemOrange, roughness: roughness, isMetallic: false)
        case .bed: return SimpleMaterial(color: .systemYellow, roughness: roughness, isMetallic: false)
        case .sink:  return SimpleMaterial(color: .systemPink, roughness: roughness, isMetallic: false)
        case .washerDryer: return SimpleMaterial(color: .systemPurple, roughness: roughness, isMetallic: false)
        case .toilet: return SimpleMaterial(color: .systemTeal, roughness: roughness, isMetallic: false)
        case .bathtub: return SimpleMaterial(color: .systemIndigo, roughness: roughness, isMetallic: false)
        case .oven: return SimpleMaterial(color: .systemBrown, roughness: roughness, isMetallic: false)
        case .dishwasher: return SimpleMaterial(color: .systemRed, roughness: roughness, isMetallic: false)
        case .table: return SimpleMaterial(color: .systemMint, roughness: roughness, isMetallic: false)
        case .sofa: return SimpleMaterial(color: .systemCyan, roughness: roughness, isMetallic: false)
        case .chair: return SimpleMaterial(color: .systemGray, roughness: roughness, isMetallic: false)
        case .fireplace: return SimpleMaterial(color: .systemGray2, roughness: roughness, isMetallic: false)
        case .television: return SimpleMaterial(color: .systemGray3, roughness: roughness, isMetallic: false)
        case .stairs: return SimpleMaterial(color: .systemGray4, roughness: roughness, isMetallic: false)
        @unknown default:
            fatalError()
        }
    }

}
