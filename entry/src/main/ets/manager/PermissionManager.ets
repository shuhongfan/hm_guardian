import { bundleManager, common, Permissions } from '@kit.AbilityKit';

class PermissionManager {

  // 检查是否授权
  checkPermissions(permissions: Permissions[]) {

  }

  // 动态申请授权（首次弹窗申请）
  async requestPermissions(permissions: Permissions[]) {

  }

  /**
   * 打开系统设置的权限管理页（处理授权结果）
   */
  openPermissionSettingsPage() {
    // 1. 获取应用上下文，并通过 as 断言收窄类型为 UIAbilityContext，否则 context 默认类型无法调用 startAbility 方法
    const context = getContext() as common.UIAbilityContext
    // 2. 获取 bundle 包信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag
      .GET_BUNDLE_INFO_WITH_APPLICATION)
    // 3. 通过 startAbility 打开 系统设置 页
    context.startAbility({
      bundleName: 'com.huawei.hmos.settings', // 固定写法CV：设置页的包名
      abilityName: 'com.huawei.hmos.settings.MainAbility', // 固定写法CV：设置页的 ability 名
      uri: 'application_info_entry', // 固定写法CV：打开 设置->应用和元服务
      parameters: {
        // 打开指定应用(包)的详情页面
        // pushParams: 'com.itheima.hm_guardian'
        // 应用包名可通过 bundleManager 动态获取
        pushParams: bundleInfo.name
      }
    })
  }
}

// 导出 Manager
export const permissionManager = new PermissionManager()