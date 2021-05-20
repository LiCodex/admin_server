import Vue from 'vue'
import Router from 'vue-router'
const _import = require('./_import_' + process.env.NODE_ENV)
// in development-env not use lazy-loading, because lazy-loading too many pages will cause webpack hot update too slow. so only in production use lazy-loading;
// detail: https://panjiachen.github.io/vue-element-admin-site/#/lazy-loading

Vue.use(Router)

/* Layout */
import Layout from '../views/layout/Layout'

/**
* hidden: true                   if `hidden:true` will not show in the sidebar(default is false)
* redirect: noredirect           if `redirect:noredirect` will no redirct in the breadcrumb
* name:'router-name'             the name is used by <keep-alive> (must set!!!)
* meta : {
    title: 'title'               the name show in submenu and breadcrumb (recommend set)
    icon: 'svg-name'             the icon show in the sidebar,
  }
**/
export const constantRouterMap = [
  { path: '/login', component: _import('login/index'), hidden: true },
  { path: '/404', component: _import('404'), hidden: true },
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    name: '主页',
    hidden: true,
    children: [{
      path: 'dashboard',
      component: _import('dashboard/index')
    }]
  },
  {
    path: '/players',
    component: Layout,
    name: 'players',
    meta: { title: '后台管理', icon: 'tree' , role: [100]},
    children: [
     {
        path: 'playerop',
        name: 'playerop',
        component: _import('players/playersop'),
        meta: { title: '玩家列表', icon: 'tree' }
      },
     {
        path: 'chongzhi',
        name: 'chongzhi',
        component: _import('chongzhi/chongzhi'),
        meta: { title: '玩家充值', icon: 'tree' }
     },
		 {
		    path: 'chongzhijilu',
		    name: 'chongzhijilu',
		    component: _import('chongzhi/chongzhijilu'),
		    meta: { title: '充值记录', icon: 'tree' }
		  },
     {
        path: 'yejirecord',
        name: 'yejirecord',
        component: _import('yeji/yejirecord'),
        meta: { title: '业绩记录', icon: 'tree' }
      },
     {
		path: 'dailitixian',
		name: 'dailitixian',
		component: _import('daili/tixian'),
		meta: { title: '提现审核', icon: 'tree' }
		},
      {
        path: 'notice',
        name: 'notice',
        component: _import('settings/notice'),
        meta: { title: '滚动公告设置', icon: 'tree' }
      },
			{
			  path: 'systemgonggao',
			  name: 'systemgonggao',
			  component: _import('settings/changjianwenti'),
			  meta: { title: '系统公告设置', icon: 'tree' }
			},
//    {
//      path: 'rule',
//      name: 'rule',
//      component: _import('settings/setrule'),
//      meta: { title: '游戏规则设置', icon: 'tree' }
//    },
    ]
 },
    {
    path: '/club',
    component: Layout,
    name: '俱乐部',
    meta: { title: '俱乐部', icon: 'tree', role: ['100'] }, //页面需要的权限
    children: [
      {
        path: 'createclub',
        name: 'createclub',
        component: _import('club/createclub'),
        meta: { title: '创建俱乐部', icon: 'tree' }
      },
      {
        path: 'index',
        name: 'index',
        component: _import('club/index'),
        meta: { title: '俱乐部列表', icon: 'tree' }
      },
      {
        path: 'delclub',
        name: 'delclub',
        component: _import('club/delclub'),
        meta: { title: '删除俱乐部', icon: 'tree' }
      }
    ]
  },
 	{
    path: '/room',
    component: Layout,
    name: '房间',
    meta: { title: '房间', icon: 'tree', role: ['100'] }, //页面需要的权限
    children: [
      {
        path: 'createroom',
        name: 'createroom',
        component: _import('room/createroom'),
        meta: { title: '创建房间', icon: 'tree' }
      },
      {
        path: 'roomlist_1',
        name: 'roomlist_1',
        component: _import('room/roomlist_1'),
        meta: { title: '微型房列表', icon: 'tree' }
     },     
     {
        path: 'roomlist_2',
        name: 'roomlist_2',
        component: _import('room/roomlist_2'),
        meta: { title: '小型房列表', icon: 'tree' }
     },     
     {
        path: 'roomlist_3',
        name: 'roomlist_3',
        component: _import('room/roomlist_3'),
        meta: { title: '中型房列表', icon: 'tree' }
     },     
     {
        path: 'roomlist_4',
        name: 'roomlist_4',
        component: _import('room/roomlist_4'),
        meta: { title: '大型房列表', icon: 'tree' }
     },
    ]
  },
]

//异步挂载的路由
//动态需要根据权限加载的路由表
export const asyncRouterMap = [
  {
    path: '/settings',
    component: Layout,
    name: '设置',
    meta: { title: '设置', icon: 'tree', role: [888] }, //页面需要的权限
    children: [
      {
        path: 'notice',
        name: 'notice',
        component: _import('settings/notice'),
        meta: { title: '滚动公告设置', icon: 'tree' }
      },      
//    {
//      path: 'zixun',
//      name: 'zixun',
//      component: _import('settings/zixun'),
//      meta: { title: '资讯设置', icon: 'tree' }
//    },
//    {
//      path: 'aboutme',
//      name: 'aboutme',
//      component: _import('settings/aboutme'),
//      meta: { title: '关于我们设置', icon: 'tree' }
//    },
    ]
  },
  {
    path: '/account',
    component: Layout,
    name: '帐号管理',
    meta: { title: '帐号管理', icon: 'tree', role: [888] }, //页面需要的权限
    children: [ 
//    {
//      path: 'setusdt',
//      name: 'setusdt',
//      component: _import('account/setusdt'),
//      meta: { title: 'usdt加减', icon: 'tree' }
//    },
//    {
//      path: 'usdtjilu',
//      name: 'usdtjilu',
//      component: _import('account/usdtjilu'),
//      meta: { title: 'usdt加减记录', icon: 'tree' }
//    },
//    {
//      path: 'settbk',
//      name: 'settbk',
//      component: _import('account/settbk'),
//      meta: { title: 'tbk加减', icon: 'tree' }
//    },
//    {
//      path: 'tbkjilu',
//      name: 'tbkjilu',
//      component: _import('account/tbkjilu'),
//      meta: { title: 'tbk加减记录', icon: 'tree' }
//    },
//    {
//      path: 'teaminfo',
//      name: 'teaminfo',
//      component: _import('team/teaminfo'),
//      meta: { title: '团队信息', icon: 'tree' }
//    },
//    {
//      path: 'teshulist',
//      name: 'teshulist',
//      component: _import('info/teshulist'),
//      meta: { title: '特殊号列表', icon: 'tree' }
//    },
      // {
      //   path: 'setpermiss',
      //   name: 'setpermiss',
      //   component: _import('info/setpermiss'),
      //   meta: { title: '帐号特权设置', icon: 'tree' }
      // },
//    {
//      path: 'playerop',
//      name: 'playerop',
//      component: _import('players/playersop'),
//      meta: { title: '玩家列表', icon: 'tree' }
//    },
//    {
//      path: 'modifyplayerinfo',
//      name: 'modifyplayerinfo',
//      component: _import('players/playersinfo'),
//      meta: { title: '修改玩家信息', icon: 'tree' }
//    },
//    {
//      path: 'seterweima',
//      name: 'seterweima',
//      component: _import('players/seterweima'),
//      meta: { title: '会员设置二维码', icon: 'tree' }
//    }
    ]
  },
// {
//  path: '/settings',
//  component: Layout,
//  name: '游戏全局配置',
//  meta: { title: '游戏全局配置', icon: 'tree', role: [888] }, //页面需要的权限
//  children: [
//    {
//      path: 'setting',
//      name: 'setting',
//      component: _import('settings/setting'),
//      meta: { title: '全局配置', icon: 'tree' }
//    },
//  ]
//	},
//  {
//  path: '/manager',
//  component: Layout,
//  name: '设置管理员',
//  meta: { title: '设置管理员', icon: 'tree', role: [888] }, //页面需要的权限
//  children: [ 
//     {
//      path: 'addmanager',
//      name: 'addmanager',
//      component: _import('account/addmanager'),
//      meta: { title: '添加管理员', icon: 'tree' }
//    },
//    {
//      path: 'managerlist',
//      name: 'managerlist',
//      component: _import('account/managerlist'),
//      meta: { title: '管理员列表', icon: 'tree' }
//    },
//  ]
//  },
  { path: '*', redirect: '/404', hidden: true }
];

export default new Router({
  // mode: 'history', //后端支持可开
  scrollBehavior: () => ({ y: 0 }),
  routes: constantRouterMap
})

