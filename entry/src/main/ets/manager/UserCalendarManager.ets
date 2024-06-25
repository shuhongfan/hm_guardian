import { Permissions } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { calendarManager } from '@kit.CalendarKit';
import { permissionManager } from './PermissionManager';

class UserCalendarManager {
  private permissions: Permissions[] = [
    "ohos.permission.READ_CALENDAR",
    "ohos.permission.WRITE_CALENDAR"
  ];

  // 授权弹窗
  async requestPermissions() {
    // 申请权限
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启弹窗提示
      promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '日历清理功能需要获取权限，请在系统设置中打开日历开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
        .then((res) => {
          // 打开设置页
          if (res.index === 1) {
            permissionManager.openPermissionSettingsPage()
          }
        })
    }
  }

  // 获取默认日历
  async getDefaultCalendar() {
    const context = getContext()
    const calendarMgr = calendarManager.getCalendarManager(context)
    // 获取并保存默认账户
    return calendarMgr.getCalendar()
  }

  // 新增日程
  async addEvent(event: calendarManager.Event) {
    const calendar = await this.getDefaultCalendar()
    return calendar.addEvent(event)
  }

  // 获取所有日程
  async getEvents() {
    const calendar = await this.getDefaultCalendar()
    return await calendar.getEvents()
  }

  // 根据标题搜索日程
  async searchEvents(title: string) {
    const calendar = await this.getDefaultCalendar()
    const filter = calendarManager.EventFilter.filterByTitle(title)
    return calendar.getEvents(filter)
  }

  // 获取过期日程
  async getOverdueEvents() {
    const calendar = await this.getDefaultCalendar()
    // 添加查询条件能查询全部，0 ～ Date.now 查询所有过期日程
    const filter = calendarManager.EventFilter.filterByTime(0, Date.now())
    return calendar.getEvents(filter)
  }

  // 查询诈骗日程
  async getFraudEvents() {
    const calendar = await this.getDefaultCalendar()
    const events = await calendar.getEvents()
    return events.filter(v => {
      return /中奖|领取|http:/.test(v.title as string) || /中奖|领取|http:/.test(v.description as string)
    })
  }

  // 删除单个日程
  async deleteEvent(id: number) {
    const calendar = await this.getDefaultCalendar()
    return calendar.deleteEvent(id)
  }

  // 批量删除日程
  async deleteEvents(ids: number[]) {
    const calendar = await this.getDefaultCalendar()
    return calendar.deleteEvents(ids)
  }

}

export const userCalendarManager = new UserCalendarManager()