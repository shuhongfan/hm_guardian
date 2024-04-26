import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig, Method } from '@ohos/axios';
import { BASE_URL } from '../constants';

// 创建实例
export const axiosInstance = axios.create({
  baseURL: BASE_URL, // 请求基地址
  timeout: 1000 * 20 // 请求超时时间
})

// 添加请求拦截器
axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 对请求数据做点什么
  return config;
}, (error: AxiosError) => {
  // 对请求错误做些什么
  return Promise.reject(error);
});

// 添加响应拦截器
axiosInstance.interceptors.response.use((response: AxiosResponse) => {
  // 对响应数据做点什么
  return response;
}, (error: AxiosError) => {
  // 对响应错误做点什么
  return Promise.reject(error);
});

export interface ResponseData<T> {
  code: number
  msg: string
  result: T
  tips?: string
  resTime?: string
}

export type AxiosResponseData<T, D = null> = AxiosResponse<ResponseData<T>, D>

// 请求配置
interface RequestConfig<T> {
  url: string
  method?: Method
  params?: T
  data?: T
}

// 请求封装
export function requestInstance<DataModel = null, Params = null>(config: RequestConfig<Params>): Promise<DataModel> {
  return axiosInstance<null, DataModel>(config)
}
