import request from '@/utils/request'

export function login(username, password) {
  return request({
    url: process.env.LOGIN_URI,
    method: 'post',
    data: {
      username,
      password
    }
  })
}

export function getInfo(token) {
  return request({
    url: process.env.INFO_URI,
    method: 'get',
    params: { token }
  })
}

export function logout() {
  return request({
    url: process.env.LOGOUT_URI,
    method: 'post'
  })
}
