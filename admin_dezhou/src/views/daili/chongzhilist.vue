<template>


  <div class="app-container calendar-list-container">
    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">


      <el-table-column align="center" label="玩家ID">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.uid)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家昵称">
        <template slot-scope="scope">
          <span>{{scope.row.name}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="充值金额">
        <template slot-scope="scope">
          <span>{{scope.row.count}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="状态">
        <template slot-scope="scope">
          <span>{{scope.row.status}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="充值时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.timestamp))}}</span>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
  import { getplayers ,findplayer ,fenghao, api_setfanli } from '@/api/players'
  import { chongzhirecord_daili } from '@/api/record'

  const defaultForm = {
    uid: '',
    start_time: undefined, // 前台展示时间
    end_time: undefined // 前台展示时间
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
      	tongji:'tongji',
      	fh:'fenghao',
      	mf:'mfenghao',
      	textMap: '设置返利',
      	dialogFormVisible: false,
        dialogStatus: '',
        fanli:'',
        temp:{
        		fanli:'',
        		uid:'',
        },
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: true,
        total: null,
        uid: localStorage.getItem("uid"),
        listQuery: {
          page: 1,
          limit: 10
        },
        start: null,
        end: null
      }
    },
    filters: {
      statusFilter(status) {
        const statusMap = {
          published: 'success',
          draft: 'info',
          deleted: 'danger'
        }
        return statusMap[status]
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        
        chongzhirecord_daili(this.uid).then(response => {
          console.log(response.data)
          this.listquan = response.data
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '操作成功',
          type: 'success'
        })
      },
      setfanli(fanli,uid){
      	this.listLoading = true
        api_setfanli(fanli,uid).then(response => {
          this.handleModifyStatus()
          this.getList()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      changeinfo(walletaddr,uid) {
        this.listLoading = true
        modifywalletaddr(walletaddr,uid).then(response => {
          this.handleModifyStatus()
          this.getList()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      setfenghao(uid, fhstatus){
      	this.listLoading = true
        fenghao(uid).then(response => {
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleSizeChange(val) {
        this.listQuery.limit = val
        this.list = this.listquan.slice(0, this.listQuery.limit)
      },
      handleCurrentChange(val) {
        this.listQuery.page = val
        const begin = this.listQuery.limit * (val - 1)
        const end = this.listQuery.limit * val
        this.list = this.listquan.slice(begin, end)
      },
      getTime(timeStamp) {
        var date = new Date()
        date.setTime(timeStamp * 1000)
        var y = date.getFullYear()
        var m = date.getMonth() + 1
        m = m < 10 ? ('0' + m) : m
        var d = date.getDate()
        d = d < 10 ? ('0' + d) : d
        var h = date.getHours()
        h = h < 10 ? ('0' + h) : h
        var minute = date.getMinutes()
        var second = date.getSeconds()
        minute = minute < 10 ? ('0' + minute) : minute
        second = second < 10 ? ('0' + second) : second
        return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second
      },
      cancelEdit(row) {
        row.title = row.originalTitle
        row.edit = false
        this.$message({
          message: 'The title has been restored to the original value',
          type: 'warning'
        })
      },
      confirmEdit(row) {
        row.edit = false
        row.originalTitle = row.title
        this.$message({
          message: 'The title has been edited',
          type: 'success'
        })
      },
      getfenghaoshowtext(fenghao){
      		var text = '未封号'
      		if(fenghao == 1){
      			text = '已封号'
      		}
      		return text;
      },
      getfenghaotext(fenghao) {
      	var text = '设置封号'
        if(parseInt(fenghao) == 1){
        		text = '取消封号'
        }
        return text
      },
      draftForm() {
        this.getList()
//      this.listLoading = true
//      getplayers(this.postForm.uid).then(response => {
//        console.log(response.data)
//        this.listquan = response.data
//        this.total = response.data.length
//        this.list = this.listquan.slice(0, this.listQuery.limit)
//        this.listLoading = false
//      }).catch(() => {
//        this.listLoading = false
//      })
      },
    }
  }
</script>

<style scoped>
  .edit-input {
    padding-right: 100px;
  }
  .cancel-btn {
    position: absolute;
    right: 15px;
    top: 13px;
  }
  .fenghao{
  	color: blue;
  	font-size: larger;
  	font-style: italic;
  	background-color:red
  }
  .mfenghao{
  	color: blue;
  }
  .tongji{
  	color: red;
  }
  img {    
	 transform: scale(1);          /*图片原始大小1倍*/
	 transition: all ease 0.5s; }  /*图片放大所用时间*/
	
	
	 img.active {     
	 transform: scale(3);          /*图片需要放大3倍*/
	 position: absolute;           /*是相对于前面的容器定位的，此处要放大的图片，不能使用position：relative；以及float，否则会导致z-index无效*/
	 z-index: 100; 
	 }   
</style>
