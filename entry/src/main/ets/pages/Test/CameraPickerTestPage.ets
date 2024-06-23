import { camera, cameraPicker } from '@kit.CameraKit'
import { fileIo, fileUri } from '@kit.CoreFileKit'

/**
 *  HarmonyOS 的两种路径格式
 *     1. path 路径    /data/storage/el2/xxx
 *     2. uri 路径     file://xxx
 *   路径转换：
 *     fileUri.getUriFromPath(path) 可把 path 路径转换为 uri 路径
 *   温馨提示：
 *     path 路径不能用于 Image 组件渲染，需要转换成 uri 路径后才能用于 Image 组件渲染
 */
@Entry
@Component
struct CameraPickerTestPage {
  @State imageUri: string = ''

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('拍照')
            .onClick(async () => {
              // cameraPicker 无需授权，直接调用原生的相机拍照
              const pickerResult = await cameraPicker.pick(
                getContext(), // 应用上下文
                [cameraPicker.PickerMediaType.PHOTO], // 媒体类型，PHOTO 照片 / VIDEO 视频
                {
                  cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK, // BACK 后置摄像头 / FRONT 前置摄像头
                }
              )
              AlertDialog.show({ message: JSON.stringify(pickerResult, null, 2) })
              // 如果拍照成功
              if (pickerResult.resultUri && pickerResult.resultCode === 0) {
                // 保存照片 uri
                this.imageUri = pickerResult.resultUri
              }
            })
          Button('隐私相册-保存到应用沙箱')
            .onClick(async () => {
              // 获取应用上下文
              const context = getContext()
              const path = context.filesDir + '/' + 'test.jpg'
              const uri = fileUri.getUriFromPath(path)
              // 注意：写入图片到文件，需要设置可写模式
              fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
              const pickerResult = await cameraPicker.pick(
                getContext(),
                [cameraPicker.PickerMediaType.PHOTO],
                {
                  cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
                  // 把 path 转换成 uri 路径
                  saveUri: uri
                }
              )
              AlertDialog.show({ message: JSON.stringify({ path, uri }, null, 2) })
              if (pickerResult.resultUri && pickerResult.resultCode === 0) {
                this.imageUri = pickerResult.resultUri
              }
            })
          Image(this.imageUri)
            .width(100)
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('cameraPicker')
    .titleMode(NavigationTitleMode.Mini)
  }
}