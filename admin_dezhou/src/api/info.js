import request from '@/utils/request'

export function setcoin(data) {
	console.log(JSON.stringify(data))
  var url = process.env.BASE_API + '/setcoin?coin=' + data.coin + '&uid=' + data.useruid
  console.log(url)
  return request({
    url: url,
    method: 'get'
  })
}

export function getcoinrecord(uid) {
  return request({
    url: process.env.BASE_API + '/getcoinrecord?uid=' + uid,
    method: 'get'
  })
}

export function getchoushuirecord(start,end) {
  return request({
    url: process.env.BASE_API + '/getchoushuirecord?start=' + start + '&end1=' + end,
    method: 'get'
  })
}

export function getadmins(type) {
	console.log('type:' + type)
  return request({
    url: process.env.BASE_API + '/getadmins?type=' + type,
    method: 'get'
  })
}

export function getteshulist(type) {
  console.log('type:' + type)
  return request({
    url: process.env.BASE_API + '/getteshulist?type=' + type,
    method: 'get'
  })
}


export function queryplayer(finduid) {
	console.log('_________uid:' + finduid)
  return request({
    url: process.env.BASE_API + '/queryplayer?fuid=' + finduid,
    method: 'get'
  })
}

export function setteshu(uid,teshu) {
	console.log('_________uid:' + uid)
	if(parseInt(teshu) == 1){
		teshu = 0
	}else{
		teshu = 1
	}
  return request({
    url: process.env.BASE_API + '/setrole?setuid=' + uid +"&teshu="+teshu,
    method: 'get'
  })
}


export function getorderlistrecord(orderid,uid) {
	var orid = ''
	var fuid = ''
	console.log("ordeid = " + orderid)
	console.log("___uid = " + uid)
	if(orderid == null){
		orid = ''
	}else{
		orid = orderid
	}
	if(uid == null){
		fuid = ''
	}else{
		fuid = uid
	}
  return request({
    url: process.env.BASE_API + '/mk_getallorder?id='+orid + '&fuid='+fuid,
    method: 'get'
  })
}

export function getorderlist() {
  return request({
    url: process.env.BASE_API + '/mk_gettousulist',
    method: 'get'
  })
}

export function queryorderid(orderid) {
	console.log('order id = ' + orderid)
  return request({
    url: process.env.BASE_API + '/mk_findid?id=' + orderid,
    method: 'get'
  })
}

export function terminatorder(orderid) {
	console.log('order id = ' + orderid)
  return request({
    url: process.env.BASE_API + '/mk_endid?id=' + orderid,
    method: 'get'
  })
}


export function querytixian(orderid,fuid) {
	console.log('order id = ' + orderid)
	if(orderid == null){
		orderid = ''
	}
	if(fuid == null){
		fuid = ''
	}
  return request({
    url: process.env.BASE_API + '/tixianlist?orderid=' + orderid + "&fuid="+ fuid,
    method: 'get'
  })
}


export function allowtibi(orderid,opadmin) {
	console.log('order id = ' + orderid)
	if(orderid == null){
		orderid = ''
	}
  return request({
    url: process.env.BASE_API + '/allowtixian?orderid=' + orderid + "&op=" + opadmin,
    method: 'get'
  })
}

export function decltibi(orderid,opadmin) {
	console.log('order id = ' + orderid)
	if(orderid == null){
		orderid = ''
	}
  return request({
    url: process.env.BASE_API + '/decltixian?orderid=' + orderid + '&op=' + opadmin,
    method: 'get'
  })
}

export function getquanwangdata() {
  return request({
    url: process.env.BASE_API + '/getquanwangdata',
    method: 'get'
  })
}
