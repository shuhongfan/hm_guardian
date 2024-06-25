import { calendarManager } from '@kit.CalendarKit';
import _ from '@wolfx/lodash';
import dayjs from 'dayjs';
import { TitleDividerComp } from '../../common/components/TitleDividerComp';
import { userCalendarManager } from '../../manager';
import { promptAction } from '@kit.ArkUI';

// 日程信息
interface GroupItem {
  year: string
  list: calendarManager.Event[]
}

// 过期日程
@Entry
@Component
struct CalendarOverduePage {
  @State list: calendarManager.Event[] = []
  @State activeEvent: calendarManager.Event | null = null
  @State groupList: GroupItem[] = []
  @State isEditing: boolean = false
  @State isShowSheet: boolean = false
  @State selectedNames: string[] = []

  onPageShow() {
    this.getData()
  }

  // 查询过期日程，并按年份编组
  async getData() {
    this.list = await userCalendarManager.getOverdueEvents()
    // 通过 lodash 的 _.groupBy 方法，把日程列表按年份编组
    //   返回值为对象  { "2024": [日程列表], "2023": [日程列表] }
    const groupedData = _.groupBy(this.list, item => dayjs(item.endTime)
      .format('YYYY年'))
    // 通过 lodash 的 _.map 方法，把对象映射成数组
    // 对象： { "2024": [日程列表], "2023": [日程列表] }
    //  _.map 映射后
    // 数组：[{ year: "2024", list: [日程列表] },{ year: "2023", list: [日程列表] }]
    this.groupList = _.map(groupedData, (item, index): GroupItem => ({
      year: index, // 年份
      list: item, // 日程列表
    }));
  }

  // 侧滑删除日程
  async deleteEvent(id: number) {
    promptAction.showToast({ message: '正在删除中，请稍等...', duration: 10000 })
    // 删除日程
    await userCalendarManager.deleteEvent(id)
    // 重新获取日程
    await this.getData()
    // 删除提示，比较删除前后的数量
    promptAction.showToast({ message: '删除成功' })
  }

  // 批量删除选中的日程
  async deleteSelectedEvents() {
    promptAction.showToast({ message: '正在清理中，请稍等...', duration: 10000 })
    // 批量删除日程
    await userCalendarManager.deleteEvents(this.selectedNames.map(v => Number(v)))
    // 重新获取日程
    await this.getData()
    // 关闭编辑状态
    this.isEditing = false
    // 删除提示，比较删除前后的数量
    promptAction.showToast({ message: '批量删除成功' })
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text(this.isEditing ? '完成' : '清理')
        .fontSize(16)
        .fontColor($r('app.color.font'))
        .onClick(() => {
          this.isEditing = !this.isEditing
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  @Builder
  ListHeader(title: string) {
    TitleDividerComp({ title: title })
  }

  @Builder
  swipeActionEnd(id: number) {
    Row() {
      Button("删除")
        .type(ButtonType.Normal)
        .height('100%')
        .fontSize(14)
        .backgroundColor($r('app.color.danger'))
        .onClick(() => {
          // TODO：删除
          this.deleteEvent(id)
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  SheetBuilder() {
    Column({ space: 20 }) {
      if (this.activeEvent) {
        Column({ space: 10 }) {
          Text(this.activeEvent.title)
            .fontSize(18)
            .fontColor($r('app.color.font'))
            .textAlign(TextAlign.Center)
          Text(this.activeEvent.description)
            .fontSize(16)
            .fontColor($r('app.color.font2'))
            .textAlign(TextAlign.Center)
        }

        Text() {
          Span(dayjs(this.activeEvent.startTime)
            .format('YYYY.MM.DD ddd HH:mm'))
          Span('\n至 ')
          Span(dayjs(this.activeEvent.endTime)
            .format('YYYY.MM.DD ddd HH:mm'))
        }
        .fontSize(14)
        .fontColor($r('app.color.font_sub'))
        .textAlign(TextAlign.Center)
        .lineHeight(25)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Navigation() {
      Column() {
        List() {
          ForEach(this.groupList, (item: GroupItem) => {
            ListItemGroup({ header: this.ListHeader(item.year) }) {
              ForEach(item.list, (event: calendarManager.Event) => {
                ListItem() {
                  Row() {
                    Checkbox({ name: event.id?.toString() })
                      .shape(CheckBoxShape.CIRCLE)
                      .visibility(this.isEditing ? Visibility.Visible : Visibility.None)
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
                    this.isShowSheet = true
                    this.activeEvent = event
                  })
                }
                .swipeAction({
                  end: {
                    builder: () => { this.swipeActionEnd(event.id) }
                  }
                })
              })
            }
            .divider({
              strokeWidth: 1,
              color: $r('app.color.border'),
              startMargin: 15,
              endMargin: 15
            })
          })
        }
        .sticky(StickyStyle.Header)
        .width('100%')
        .height('100%')
        .layoutWeight(1)

        Row({ space: 10 }) {
          Column() {
            // 多选框群组
            CheckboxGroup()
              .onChange((event) => {
                this.selectedNames = event.name
              })
            Text('全选')
              .fontSize(12)
              .fontColor($r('app.color.font2'))
          }

          Button('删除')
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .borderRadius(10)
            .backgroundColor($r('app.color.danger'))
            .enabled(this.selectedNames.length > 0)
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
        .visibility(this.isEditing ? Visibility.Visible : Visibility.None)
      }
    }
    .title('过期日程')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())
    .bindSheet($$this.isShowSheet, this.SheetBuilder(), {
      backgroundColor: Color.White,
      showClose: false
    })
  }
}