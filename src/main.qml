import QtQuick 2.1 as QQ2
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0

Entity {

    components: [
        rendSettings,
        inputSettings
    ]

    InputSettings { id: inputSettings }

    RenderSettings {
        id: rendSettings
        activeFrameGraph: RenderSurfaceSelector {
            Viewport {
                normalizedRect: Qt.rect(0,0,1,1)
                CameraSelector {
                    camera: camera
                    ClearBuffers {
                        buffers: ClearBuffers.ColorDepthBuffer
                    }
                }
            }
        }

    }

    Camera {
        id: camera
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: 60
        aspectRatio: _window.width / _window.height
        nearPlane: 0.01
        farPlane: 1000.0
        position: Qt.vector3d(0.0, 10.0, 20.0)
        viewCenter: Qt.vector3d(0.0, 0.0, 0.0)
        upVector: Qt.vector3d(0.0, 1.0, 0.0)
    }

    SkyboxEntity {
       baseName: "file:./../skybox/park"
       extension: ".png"
   }

    FirstPersonCameraController { camera: camera }

    Entity {
        PlaneMesh {
            id: pm
            width: 20
            height: 20
        }
        PhongMaterial {
            id: pmm
            ambient: Qt.rgba(0.0,0.0,0.7,1)
        }
        components: [ pm, pmm ]
    }


    Entity {

        id: myEntity
        property matrix4x4 instTransform: Qt.matrix4x4(   // identity matrix
                                               1,0,0,0,
                                               0,1,0,0,
                                               0,0,1,0,
                                               0,0,0,1)

        GeometryRenderer {
            id: gr
            geometry: _instg
            instanceCount: _instg.count
        }

        Transform {
            id: trr
            translation: Qt.vector3d(0,1.5,0)
        }

        Material {
            id: grm

            parameters: [
                Parameter { name: "ka"; value: Qt.rgba(0.05, 0.05, 0.05, 1.0) },
                Parameter { name: "kd"; value: Qt.rgba(0.7, 0.7, 0.7, 1.0) },
                Parameter { name: "ks"; value: Qt.rgba(0.01, 0.01, 0.01, 1.0) },
                Parameter { name: "shininess"; value: 150. },
                Parameter { name: "inst"; value: myEntity.instTransform },
                Parameter { name: "instNormal"; value: _instg.normalMatrix( myEntity.instTransform ) }
            ]

            effect: Effect {
                techniques: Technique {
                    graphicsApiFilter { api: GraphicsApiFilter.OpenGL; profile: GraphicsApiFilter.CoreProfile; majorVersion: 3; minorVersion: 1 }
                    renderPasses: [
                        RenderPass {
                            shaderProgram: ShaderProgram {
                                vertexShaderCode: loadSource("qrc:/shaders/instanced.vert")
                                fragmentShaderCode: loadSource("qrc:/shaders/instanced.frag")
                            }
                        }
                    ]
                }
            }
        }

        components:  [ gr, grm, trr ]
    }
}