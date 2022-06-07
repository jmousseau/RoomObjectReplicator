# RoomObjectReplicator

As Apple states, [`RoomPlan`](https://developer.apple.com/documentation/RoomPlan) allows one to
create a 3D model of a room. But what if we ignored room reconstruction and instead enhanced ARKit
by piggy-backing off `RoomPlan`'s underlying object recognition technology. Specifically, for each
`CapturedRoom.Object` we can add a custom `ARAnchor` subclass instance.

The `RoomObjectReplicator` class does exactly that, creating and updating an `RoomObjectAnchor` for
each object in the captured room. Once you have a replicator instantiated, anchor the objects in
the capture session delegate methods:

```swift
func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
}

func captureSession(_ session: RoomCaptureSession, didChange room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
}

func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
}

func captureSession(_ session: RoomCaptureSession, didRemove room: CapturedRoom) {
    replicator.anchor(objects: room.objects, in: session)
}
```

Mirroring room object as anchors allows us to easily integrate other Frameworks such as RealityKit.
The `RoomObjectEntity` is a custom RealityKit entity that will anchor to `RoomObjectAnchor`s. The
`RoomObjectSystem` will then resize a box model to match the room object's dimensions.

```swift
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    view.scene.addRoomObjectEntities(for: anchors)
}

func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    view.scene.updateRoomObjectEntities(for: anchors)
}
```
