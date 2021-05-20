<template>
  <div class="app-container calendar-list-container">
    <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">
        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <!--<el-row>
                  <el-col :span="5">
                    <el-form-item label-width="80px" label="玩家ID" class="postInfo-container-item">
                      <el-input v-model="postForm.uid" type="number"  placeholder="请输入玩家ID" style="width: 150px">
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-button  type="warning" @click="draftForm" style="margin-left: 180px">搜索</el-button>
                </el-row>-->
                
                 <!--<el-row>
				  <el-col :span="24">
				  	<el-form-item label-width="120px" label="游戏总人数:">
                      <span v-model="postForm.totalcount">{{postForm.totalcount}}</span>
                   </el-form-item>
				  </el-col>
				</el-row>
				<el-row>
				  <el-col :span="24">
				  	<el-form-item label-width="120px" label="有效人数:">
                      <span v-model="postForm.youxiao">{{postForm.youxiao}}</span>
                   </el-form-item>
				  </el-col>
				</el-row>-->
              </div>
            </el-col>
          </el-row>
        </div>
      </el-form>

    </div>


    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">
      <el-table-column align="center" label="玩家ID">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.id)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家昵称">
        <template slot-scope="scope">
          <span>{{scope.row.nickname}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="金币">
        <template slot-scope="scope">
          <span>{{scope.row.coin}}</span>
        </template>
      </el-table-column>
     <el-table-column align="center" label="上级">
        <template slot-scope="scope">
          <span>{{scope.row.shangji}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="直推数">
        <template slot-scope="scope">
          <span>{{scope.row.zhitui}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="团队人数">
        <template slot-scope="scope">
          <span>{{scope.row.tuandui}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="等级">
        <template slot-scope="scope">
          <span>{{scope.row.level}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="等级名">
        <template slot-scope="scope">
          <span>{{scope.row.levelname}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="业绩">
        <template slot-scope="scope">
          <span>{{scope.row.yeji}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="可提佣金">
        <template slot-scope="scope">
          <span>{{scope.row.yongyin}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="俱乐部ID">
        <template slot-scope="scope">
          <span>{{scope.row.clubid}}</span>
        </template>
      </el-table-column>
       <el-table-column align="center" label="封号">
        <template slot-scope="scope">
          <span>{{scope.row.status}}</span>
        </template>
      </el-table-column>
      <!--<el-table-column align="center" label="封号">
        <template slot-scope="scope">
          <span :class="scope.row.fenghao == 1?fh:mf">{{getfenghaoshowtext(scope.row.fenghao) }}</span>
        </template>
      </el-table-column>-->

      <el-table-column align="center" label="电话">
        <template slot-scope="scope">
          <span>{{scope.row.phone}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="注册时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.create))}}</span>
        </template>
      </el-table-column>
      <el-table-column :width='120' align="center" label="设置封号">
        <template slot-scope="scope">
          <div v-if="scope.row.status==1">
         	<el-button type="danger" @click="setfenghao(parseInt(scope.row.id))">{{  getfenghaotext(scope.row.status) }}</el-button>
          </div>
          <div v-else>
          	  <el-button type="primary" @click="setfenghao(parseInt(scope.row.id))">{{  getfenghaotext(scope.row.status) }}</el-button>
          </div>
        </template>
      </el-table-column>
      
    </el-table>
    
    
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>
    
  </div>
</template>

<script>
//import { getplayers ,findplayer , modifywalletaddr ,fenghao, setdaili } from '@/api/players'
import { getplayers ,api_setfenghao } from '@/api/game'

  const defaultForm = {
    uid: '',
    start_time: undefined, // 前台展示时间
    end_time: undefined // 前台展示时间
  }

  export default {
    name: 'inlineEditTable',
    tongji:'tongji',
    yifeng: 'yifeng',
    meifeng:'meifeng',
    data() {
      return {
      	fh:'fenghao',
      	mf:'mfenghao',
      	textMap: '修改钱包地址',
      	dialogFormVisible: false,
        dialogStatus: '',
        walletaddr:'',
        temp:{
        		walletaddr:'',
        		uid:'',
        },
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: true,
        total: null,
        uid: localStorage.getItem("username"),
        listQuery: {
          page: 1,
          limit: 10
        },
        curpage: 1,
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
        getplayers(this.curpage).then(response => {
          console.log(response.data)
          var data = response.data.all
          this.listquan = data
          this.total = data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      setfenghao(uid,flag){
      	 this.listLoading = true
        api_setfenghao(uid).then(response => {
          console.log(response.data)
          this.getList()
//        var data = response.data.all;
//        this.listquan = data
//        this.total = data.length
//        this.list = this.listquan.slice(0, this.listQuery.limit)
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
      getdailibtntext(daili) {
      	var text = '设置开房权'
        if(parseInt(daili) == 1){
        		text = '取消开房权'
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
  .yifeng{
  	type: "danger";
  }
  .meifeng{
  	type: "primary";
  }
  .tongji{
  	font-size: larger;
  	color: red;
  }
</style>
