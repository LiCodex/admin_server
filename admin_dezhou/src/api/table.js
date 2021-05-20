import request from '@/utils/request'

export function getList(token) {
  return request({
    url: '/table/list',
    method: 'get',
    params: { token }
  })
}
