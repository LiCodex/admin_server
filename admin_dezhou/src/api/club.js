import request from '@/utils/request'

export function createclub(type) {
  return request({
    url: process.env.BASE_API + '/createclub?t=' + type.type + '&hallname=' + type.hallname + '&hallintroduce=' + type.hallintroduce + '&token=' + type.token + '&guid=' + type.guanid,
    method: 'get'
  })
}

export function gethalllist(type) {
  return request({
    url: process.env.BASE_API + '/listclub',
    method: 'get'
  })
}

export function delclub(data) {
  return request({
    url: process.env.BASE_API + '/delclub?hallkey=' + data.hallkey,
    method: 'get'
  })
}

