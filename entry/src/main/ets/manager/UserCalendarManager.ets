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
}

export const userCalendarManager = new UserCalendarManager()