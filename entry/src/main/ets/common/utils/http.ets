import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BASE_URL, LoginInfoResponse, LOGIN_INFO } from '../constants';
import { JSON } from '@kit.ArkTS';
import { promptAction, router } from '@kit.ArkUI';

/**
 * 后端响应基本类型
 */
export interface ServiceResponse<T> {
  /** 请求码，200为成功，300及300以上为请求失败 */
  code: number;
  msg: string;
  resTime: Date;
  result: T;
  tips: string;
}

// type 类型别名,保存类型
// 三层对象嵌套：Axios 响应类型 > 后端响应基本类型 > 不同接口响应的类型
export type AxiosResponseData<Result = null> = AxiosResponse<ServiceResponse<Result>, null>

// 创建实例
export const axiosInstance = axios.create({
  baseURL: BASE_URL, // 请求基地址
  timeout: 1000 * 20 // 请求超时时间
})

// 添加请求拦截器
axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 每次发请求前，判断是否有 token，如果有 token 就自动添加到请求头 (headers) 中
  const loginInfo = AppStorage.get<LoginInfoResponse>(LOGIN_INFO)
  if (loginInfo?.accessToken) {
    config.headers.Authorization = loginInfo?.accessToken
  }
  // 对请求数据做点什么
  return config;
}, (error: AxiosError) => {
  // 对请求错误做些什么
  return Promise.reject(error);
});

// 添加响应拦截器
axiosInstance.interceptors.response.use((response: AxiosResponseData) => {
  console.log('interceptors.response', JSON.stringify(response))
  // 对响应数据做点什么
  if (response.data.code === 200) {
    // 业务状态码正确，才返回 response
    return response;
  } else {
    // 业务状态码错误，统一错误轻提示
    promptAction.showToast({ message: response.data.msg })
    // 返回 Promise.reject() 能主动中断 await 后续代码的执行
    return Promise.reject(response.data.msg)
  }
}, (error: AxiosError) => {
  // 401 错误统一处理
  if (error.message.includes('401')) {
    // 轻提示
    promptAction.showToast({ message: '登录信息无效，请重新登录' })
    // 跳转登录页
    router.pushUrl({ url: 'pages/User/UserLoginPage' })
    // 清空无效的用户信息
  } else if (error.message.includes('404')) {
    // 轻提示
    promptAction.showToast({ message: '请求地址无效' })
  } else {
    promptAction.showToast({ message: '未知网络错误' })
  }
  // 对响应错误做点什么
  return Promise.reject(error);
});
