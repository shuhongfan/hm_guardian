import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { BASE_URL } from '../../common/constants'
import { promptAction } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { axiosInstance } from '../../common/utils';

// 温馨提示：网络请求接口的类型，可通过 Apifox 工具生成 CV 过来
/** 账号密码登录模型 */
export interface PostUserLoginPasswdData {
  /** 用户密码 */
  passwd?: string;

  /** 用户手机号 */
  phone?: string;
}

/** 后端数据响应模型<R> */
export interface ServiceResponse<R> {
  code: number;
  msg?: string;
  resTime?: Date;
  result?: R;
  tips?: string;
}

/** 登录 Result */
export interface LoginInfoResult {
  accessToken?: string;
  avatar?: string;
  nickname?: string;
  renewalToken?: string;
}

// type 类型别名，把 axios 范型参数二的类型保存起来
type AxiosResponseData<T = null> = AxiosResponse<ServiceResponse<T>, null>

@Entry
@Component
struct AxiosTestPage {
  // 定义头像数据
  @State avatar: string = ''

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('范型参数-约束 post 请求参数')
            .onClick(async () => {
              /**
               *  axios 范型参数：
               *     第一个范型参数： 类型会被第二个范型参数覆盖掉，所以没啥用
               *     第二个范型参数： 约束后端返回数据的类型 - 重点学习
               *     第三个范型参数： 约束请求体(data)参数的类型 - 重点学习
               *
               *  温馨提示：
               *    第三方库使用 TS 语法封装，比 ArkTS 语法松散，三方库中可能会出现 any 类型
               *    但是在 ArkTS 不允许出现 any 类型，使用三方库时需要把 any 类型覆盖成明确的类型
               */
              const res =
                await axios.post<null, AxiosResponseData<LoginInfoResult>, PostUserLoginPasswdData>(
                  BASE_URL + '/user/login/passwd',
                  {
                    // 注意手机号和密码的字段容易写反了，可能返回 手机号/密码错误
                    phone: '120666666666',
                    passwd: '888itcast.CN764%...'
                  }
                )
              // promptAction.showToast({ message: '登录请求发送成功' })
              AlertDialog.show({ message: JSON.stringify(res, null, 2) })
              if (res.data.code === 200) {
                // 保存头像
                this.avatar = res.data.result?.avatar as string
              } else {
                // 显示后端错误信息
                promptAction.showToast({ message: res.data.msg })
              }
            })
          Image(this.avatar)
            .width(200)
          Divider()
            .strokeWidth(1)

          Button('创建 axios 实例-并添加拦截器')
            .onClick(async () => {
              // 0. 创建 axios 实例
              const axiosInstance = axios.create({
                baseURL: BASE_URL,
                timeout: 20 * 1000
              })

              // 注意：文档中 CV 过来拦截器的结构即可，CV 后记得把 axios 替换成 axiosInstance 实例！！！
              // 1. 添加请求拦截器
              axiosInstance.interceptors.request.use(
                (config: InternalAxiosRequestConfig) => {
                  // 统一添加 token
                  config.headers.Authorization = 'token_xxxx'
                  console.log('interceptors request', JSON.stringify(config))
                  // 对请求数据做点什么
                  return config;
                }, (error: AxiosError) => {
                // 对请求错误做些什么
                return Promise.reject(error);
              });

              // 2. 添加响应拦截器
              axiosInstance.interceptors.response.use((response: AxiosResponse) => {
                // 对响应数据做点什么
                return response;
              }, (error: AxiosError) => {
                // 对响应错误做点什么
                return Promise.reject(error);
              });

              //----------------
              const res = await axiosInstance.post<null, AxiosResponseData<LoginInfoResult>, PostUserLoginPasswdData>
              (
                '/user/login/passwd',
                {
                  phone: '120666666666',
                  passwd: '888itcast.CN764%...'
                }
              )

              if (res.data.code === 200) {
                // 保存头像
                this.avatar = res.data.result?.avatar as string
              } else {
                // 显示后端错误信息
                promptAction.showToast({ message: res.data.msg })
              }

            })
          Divider()
            .strokeWidth(1)

          Button('请求工具-发送登录请求')
            .onClick(async () => {
              const res = await axiosInstance.post<null, AxiosResponseData<LoginInfoResult>, PostUserLoginPasswdData>
              (
                '/user/login/passwd',
                { phone: '111', passwd: '222' }
              )
              // 直接书写参数正确时的逻辑即可，错误由拦截器统一处理
              this.avatar = res.data.result?.avatar as string
            })
          Button('请求工具-发送获取我的用户信息')
            .onClick(async () => {
              /** 获取用户信息 */
              interface GetUserMeResponse {
                avatar?: string;
                nickname?: string;
              }

              const res = await axiosInstance.get<null, AxiosResponseData<GetUserMeResponse>>('/user/me')
              this.avatar = res.data.result?.avatar as string
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('axios进阶用法')
    .titleMode(NavigationTitleMode.Mini)
  }
}