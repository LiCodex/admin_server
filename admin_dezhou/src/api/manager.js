import request from '@/utils/request'

export function delmanager(uid) {
	console.log(JSON.stringify(uid))
  var url = process.env.BASE_API + '/delmanager?fuid=' + uid
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function managerlist() {
  return request({
    url: process.env.BASE_API + '/managerlist',
    method: 'get'
  })
}

export function addmanager(data) {
  return request({
    url: process.env.BASE_API + '/addmanager?' + data,
    method: 'get'
  })
}

export function daililist(uid) {
	console.log(JSON.stringify(uid))
  var url = process.env.BASE_API + '/daililist?fuid=' + uid
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}