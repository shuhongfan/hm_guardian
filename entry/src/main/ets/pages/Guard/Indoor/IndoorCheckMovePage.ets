import { router } from '@kit.ArkUI'
import { sensor } from '@kit.SensorServiceKit'

// 检测手机移动
@Entry
@Component
struct IndoorCheckMovePage {
  // 动画旋转角度
  @State gradientRotateAngle: number = 0
  // 是否静止状态
  @State isStatic: boolean = false
  // 传感器数据
  @State sensorResponse: sensor.AccelerometerResponse | null = null

  aboutToAppear() {
    this.startSensor()
  }

  // 页面卸载，取消传感器订阅，释放资源
  aboutToDisappear() {
    this.stopSensor()
  }

  // 检测手机是否静止
  checkStatic(value: sensor.AccelerometerResponse, oldValue: sensor.AccelerometerResponse) {
    // Math.abs  计算绝对值，用于判断误差范围，只要误差范围小于等于 1 都认为设备静止
    return (
      Math.abs(value.x - oldValue.x) <= 1 &&
        Math.abs(value.y - oldValue.y) <= 1 &&
        Math.abs(value.z - oldValue.z) <= 1
    )
  }

  // 订阅传感器
  startSensor() {
    sensor.on(sensor.SensorId.ACCELEROMETER, (response) => {
      // 先保存第一次传感器的数据
      if (this.sensorResponse === null) {
        this.sensorResponse = response
        return
      }
      // 对比两次传感器的值，如果在误差范围内则为静止
      //   response               当前传感器的数据
      //   this.sensorResponse    上次保存的传感器数据
      this.isStatic = this.checkStatic(response, this.sensorResponse)
      // 保存传感器数据，用于下次比较
      this.sensorResponse = response
    }, { interval: 'game' })
  }

  // 取消传感器订阅
  stopSensor() {
    sensor.off(sensor.SensorId.ACCELEROMETER)
  }

  @Styles
  circleSize(){
    .height(150)
    .aspectRatio(1)
    .borderRadius(150 / 2)
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 页面内容
        Column({ space: 10 }) {
          Stack() {
            // 背景 1
            Row()
              .circleSize()
              .backgroundColor('#FFFBFCFE')
              .scale({ x: 220 / 150, y: 220 / 150 })
            // 背景 2
            Row()
              .circleSize()
              .backgroundColor('#080A59F7')
              .scale({ x: 180 / 150, y: 180 / 150 })
            // 渐变色 - 带动画效果
            Row()
              .circleSize()
              .linearGradient({ angle: 0, colors: [['#47eeff', 0], ['#29a6ff', 1]] })
              .rotate({ angle: this.gradientRotateAngle })
              .animation({
                duration: 2 * 1000, // 单次时长
                iterations: -1, // 设置-1表示动画无限循环
                curve: Curve.Linear // 匀速动画
              })
              .onAppear(() => {
                this.gradientRotateAngle = 360
              })

            // 图标区域
            Stack() {
              // 点点图
              Image($r('app.media.ic_lab_move_detect_top'))
                .circleSize()
              // 手机扫描中
              Image(this.isStatic ? $r('app.media.ic_lab_move_detect_protect') :
              $r('app.media.ic_lab_move_detect_phone'))
                .height(80)
            }
          }
          .margin({ top: -250 })

          // 提示文字
          Text(this.isStatic ? '保护中' : '扫描中')
            .fontSize(20)
            .fontWeight(500)
            .fontColor($r('app.color.brand'))
          Text('保持手机静止，以激活防移动模式')
            .fontSize(14)
          Text('是否静止：' + this.isStatic)
          Text('传感器数据：' + JSON.stringify(this.sensorResponse))
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')

        // 底部按钮
        Column() {
          Button('停止激活')
            .type(ButtonType.Normal)
            .borderRadius(10)
            .width('100%')
            .backgroundColor($r('app.color.brand'))
            .onClick(() => {
              router.back()
            })
        }
        .padding({ left: 20, right: 20, bottom: 30 })
      }
      .width('100%')
      .height('100%')
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}