import request from '@/utils/request'

export function getplayers(uid) {
  return request({
    url: process.env.BASE_API + '/getplayers?fuid=' + uid,
    method: 'get'
  })
}

export function changepwd(data) {
  var url = process.env.BASE_API + '/changepwd?' + data + '&uid=' + localStorage.getItem("username")
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function changebankpwd(data) {
  var url = process.env.BASE_API + '/changebankpwd?' + data + '&uid=' + localStorage.getItem("username")
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function setblack(uid) {
  return request({
    url: process.env.BASE_API + '/sethei?uid=' + uid,
    method: 'get'
  })
}

export function fenghao(uid) {
  return request({
    url: process.env.BASE_API + '/fenghao?fuid=' + uid ,
    method: 'get'
  })
}

export function setdaili(uid) {
  return request({
    url: process.env.BASE_API + '/setdaili?fuid=' + uid ,
    method: 'get'
  })
}

export function modifywalletaddr(newwallet,uid) {
	console.log("new address :" + newwallet)
  return request({
    url: process.env.BASE_API + '/modifywalletaddr?newwallet=' + newwallet +"&puid=" + uid,
    method: 'get'
  })
}

export function modifyplayerinf(data) {
  var url = process.env.BASE_API + '/modifyplayerinf?' + data
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function uploaderweima(data) {
	var param = 'fuid='+data.uid + '&weixinurl='+ data.url + '&zhifubaourl=' + data.url1
  var url = process.env.BASE_API + '/modifyerweima?' + param
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function uploadkefumingpian(data) {
	var d = {}
	d.url1 = data.kf1
	d.url2 = data.kf2
	console.log('data: ' + JSON.stringify(data))
	
	var config = {}
	config['erweimaurl'] = d
	var jsstr = ''+JSON.stringify(config)
	console.log("str:" + jsstr)
	
  var url = process.env.BASE_API + '/setkefumingpian?data=' + jsstr
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}


