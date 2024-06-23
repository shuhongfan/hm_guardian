import { FaultLogger } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct FaultLoggerTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('查询故障日志')
            .onClick(async () => {
              // 获取当前进程故障信息
              const logs = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
              AlertDialog.show({ message: JSON.stringify(logs, null, 2) })
            })
          Button('抛出异常-导致程序闪退')
            .onClick(() => {
              // throw 抛出异常，程序闪退
              throw new Error('my error')
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('faultLogger')
    .titleMode(NavigationTitleMode.Mini)
  }
}