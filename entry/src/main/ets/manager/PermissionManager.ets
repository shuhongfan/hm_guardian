import { Permissions } from '@kit.AbilityKit';

class PermissionManager {

  // 检查是否授权
  checkPermissions(permissions: Permissions[]) {

  }

  // 动态申请授权（首次弹窗申请）
  async requestPermissions(permissions: Permissions[]) {

  }

  // 打开系统设置的权限管理页（处理授权结果）
  openPermissionSettingsPage() {

  }
}

// 导出 Manager
export const permissionManager = new PermissionManager()