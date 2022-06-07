//
//  RoomObjectSystem.swift
//  RoomObjectReplicator
//
//  Created by Jack Mousseau on 6/6/22.
//

import RealityFoundation

public struct RoomObjectComponent: Component {

    public var dimensions: simd_float3 = .zero

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
        self.init(dimensions: anchor.dimensions)
        components.set([AnchoringComponent(anchor)])
    }

    public init(dimensions: simd_float3) {
        super.init()

        let mesh = MeshResource.generateBox(size: .one, cornerRadius: .zero)
        let material = SimpleMaterial(color: .systemYellow, roughness: 0.27, isMetallic: false)
        let model = ModelComponent(mesh: mesh, materials: [material])
        let roomObject = RoomObjectComponent(dimensions: dimensions)
        components.set([model, roomObject])
    }

}

class RoomObjectSystem: System {

    let roomObjectAnchorQuery: EntityQuery

    required init(scene: Scene) {
        roomObjectAnchorQuery = EntityQuery(where: .has(RoomObjectComponent.self) && .has(ModelComponent.self))
    }

    func update(context: SceneUpdateContext) {
        context.scene.performQuery(roomObjectAnchorQuery).forEach { entity in
            guard let entity = entity as? Entity & HasModel & HasRoomObjectComponent else { return }
            guard let dimensions = entity.roomObject?.dimensions else { return }
            entity.scale = dimensions
        }
    }

}
