import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

class PermissionManager {

  /**
   * 检查是否授权
   * @param permissions 权限列表
   * @returns 返回授权结果
   */
  checkPermissions(permissions: Permissions[]) {
    // 1. 创建应用权限管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 2. 获取 bundle 包信息，Sync 写法
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    // 3. 提取 tokenID
    const tokenID = bundleInfo.appInfo.accessTokenId
    // 4. 检测是否授权，Sync 写法，升级成遍历权限组（数组）！！！
    const grantStatus = permissions.map(item => atManager.checkAccessTokenSync(tokenID, item))
    // 返回权限数组的检测结果
    return grantStatus.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    // 温馨提示：当前函数没有用到 Promise，都是用 Sync 函数，好处：可直接再组件渲染权限检测结果
  }

  /**
   * 动态申请授权（首次弹窗申请）
   * @param permissions 权限列表
   * @returns 返回授权结果，授权成功为 Promise.resolve(), 拒绝授权为 Promise.reject()
   */
  async requestPermissions(permissions: Permissions[]) {
    // 1. 创建应用权限管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 2. 向用户申请 user_grant 权限（温馨提示：首次申请时会弹窗，后续申请则不会再出现弹窗）
    const requestResult = await atManager.requestPermissionsFromUser(
      getContext(), // 应用上下文
      permissions   // 参数：权限列表(数组)
    )
    // 通过 every 检查权限是否都成功授权
    const isAuth = requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    // Promise.resolve()   返回 Promise 成功，await 后续代码，正常执行
    // Promise.reject()    返回 Promise 错误，await 后续代码，不被执行，Promise.reject() 的结果可被 catch 捕获
    return isAuth === true ? Promise.resolve(true) : Promise.reject(false)
  }

  /**
   * 打开系统设置的权限管理页（处理授权结果）
   */
  openPermissionSettingsPage() {
    // 1. 获取应用上下文，并通过 as 断言收窄类型为 UIAbilityContext，否则 context 默认类型无法调用 startAbility 方法
    const context = getContext() as common.UIAbilityContext
    // 2. 获取 bundle 包信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
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