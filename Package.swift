// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RoomObjectReplicator",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RoomObjectReplicator",
            targets: [
                "RoomObjectReplicator"
            ]
        )
    ],
    targets: [
        .target(
            name: "RoomObjectReplicator"
        )
    ]
)
