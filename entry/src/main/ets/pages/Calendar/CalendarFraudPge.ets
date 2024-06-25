import { calendarManager } from '@kit.CalendarKit';
import dayjs from 'dayjs';
import { TitleDividerComp } from '../../common/components/TitleDividerComp';
import { userCalendarManager } from '../../manager';
import { promptAction, router } from '@kit.ArkUI';


@Entry
@Component
struct CalendarFraudPage {
  // 日程列表
  @State list: calendarManager.Event[] = []
  // 选中项
  @State selectedName: string[] = []

  aboutToAppear() {
    this.getData()
  }

  async getData() {
    this.list = await userCalendarManager.getFraudEvents()
    this.selectedName = this.list.map(v => String(v.id))
  }

  // 清理选中日程
  async deleteSelectedEvents() {
    promptAction.showToast({ message: '正在清理中，请稍等...', duration: 10000 })
    await userCalendarManager.deleteEvents(this.selectedName.map(v => Number(v)))
    promptAction.showToast({ message: '清理成功' })
    setTimeout(() => {
      router.back()
    }, 1000)
  }

  build() {
    Navigation() {
      Column() {
        TitleDividerComp({ title: `诈骗日历 ${this.list.length} 条` })
        List() {
          ForEach(this.list, (event: calendarManager.Event) => {
            ListItem() {
              Row() {
                Checkbox({ name: event.id?.toString() })
                  .select(true)
                Text(event.title)
                  .fontSize(14)
                  .fontColor($r('app.color.font2'))
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .padding({ right: 20 })
                Text(dayjs(event.endTime)
                  .format('YYYY.MM.DD'))
                  .fontSize(14)
                  .fontColor($r('app.color.font_sub'))
              }
              .height(40)
              .padding({ left: 15, right: 15 })
              .onClick(() => {

              })
            }
          })
        }
        .divider({
          strokeWidth: 1,
          color: $r('app.color.border'),
          startMargin: 15,
          endMargin: 15
        })
        .width('100%')
        .height('100%')
        .layoutWeight(1)

        Row({ space: 10 }) {
          Column() {
            // 多选框群组
            CheckboxGroup()
              .selectAll(true)
              .onChange((event) => {
                this.selectedName = event.name
              })
            Text('全选')
              .fontSize(12)
              .fontColor($r('app.color.font2'))
          }

          Button('一键清理')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .borderRadius(10)
            .backgroundColor($r('app.color.brand'))
            .enabled(this.selectedName.length > 0)
            .onClick(() => {
              // TODO：批量删除
              this.deleteSelectedEvents()
            })
        }
        .height(76)
        .padding({ left: 20, right: 20 })
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .border({ width: { top: 1 }, color: $r('app.color.border') })
      }
    }
    .title('诈骗日历')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}