import { camera, cameraPicker } from '@kit.CameraKit'

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
              const pickerResult = await cameraPicker.pick(
                getContext(),
                [cameraPicker.PickerMediaType.PHOTO],
                {
                  cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
                }
              )
              // AlertDialog.show({ message: JSON.stringify(pickerResult, null, 2) })
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