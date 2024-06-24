// Torch 手电筒（调用闪光灯硬件）
import { camera } from '@kit.CameraKit'

@Entry
@Component
struct TorchTestPage {
  @State isTorchSupported: boolean = false

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('检测是否支持手电筒模式')
            .onClick(() => {
              const cameraManager = camera.getCameraManager(getContext())
              this.isTorchSupported = cameraManager.isTorchSupported()
            })
          Text('是否支持手电筒模式：' + this.isTorchSupported)
          Button('打开手电筒')
            .onClick(() => {
              const cameraManager = camera.getCameraManager(getContext())
              cameraManager.setTorchMode(camera.TorchMode.ON)
            })
          Button('关闭手电筒')
            .onClick(() => {
              const cameraManager = camera.getCameraManager(getContext())
              cameraManager.setTorchMode(camera.TorchMode.OFF)
            })

          Button('检测手电筒状态-开关合一')
            .onClick(() => {
              const cameraManager = camera.getCameraManager(getContext())
              if (cameraManager.getTorchMode() === camera.TorchMode.OFF) {
                cameraManager.setTorchMode(camera.TorchMode.ON)
              } else {
                cameraManager.setTorchMode(camera.TorchMode.OFF)
              }
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}