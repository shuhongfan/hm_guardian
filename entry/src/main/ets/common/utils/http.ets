import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BASE_URL } from '../constants';

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
