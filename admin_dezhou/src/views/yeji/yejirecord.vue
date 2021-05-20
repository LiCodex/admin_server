<template>
  <div class="app-container calendar-list-container">
    <div class="createPost-container">
      <el-form class="form-container" :model="postForm" ref="postForm">
        <div class="createPost-main-container">
          <el-row>
            <el-col :span="21">
              <div class="postInfo-container">
                <el-row>
                  <el-col :span="5">
                    <el-form-item label-width="80px" label="玩家ID" class="postInfo-container-item">
                      <el-input v-model="postForm.uid" type="number"  placeholder="请输入玩家ID" style="width: 150px">
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-button type="warning" @click="draftForm" style="margin-left: 180px">搜索</el-button>
                </el-row>
              </div>
            </el-col>
          </el-row>
        </div>
      </el-form>
    </div>

    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">
    	
      <el-table-column align="center" label="玩家ID">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.touid)}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家昵称">
        <template slot-scope="scope">
          <span>{{scope.row.tname}}</span>
        </template>
      </el-table-column>
      
      <el-table-column align="center" label="下级UID">
        <template slot-scope="scope">
          <span>{{scope.row.fromuid}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="玩家昵称">
        <template slot-scope="scope">
          <span>{{scope.row.fname}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="数量">
        <template slot-scope="scope">
          <span>{{scope.row.num}}</span>
        </template>
      </el-table-column>
      <!--<el-table-column align="center" label="封号">
        <template slot-scope="scope">
          <span :class="scope.row.fenghao == 1?fh:mf">{{getfenghaoshowtext(scope.row.fenghao) }}</span>
        </template>
      </el-table-column>-->
      <!--<el-table-column align="center" label="性别">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.sex)==1?'女':'男'}}</span>
        </template>
      </el-table-column> -->
      
      <el-table-column align="center" label="时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.time))}}</span>
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
  import { getyejirecord } from '@/api/tixian'
  const defaultForm = {
    uid: '',
    start_time: undefined, // 前台展示时间
    end_time: undefined // 前台展示时间
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
      	fh:'fenghao',
      	mf:'mfenghao',
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: false,
        total: null,
        uid: localStorage.getItem("username"),
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
//    this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        getyejirecord(this.postForm.uid).then(response => {
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
      modifyplayerinfo(form) {
        this.listLoading = true
        console.log(form)
        var str = {}
        for (var k in form) {
//        if (form[k] != '') {
		  if(true){
          	if(k=='uid' || k == 'name'){
          		str['f'+k] = form[k]
          	}else{
          		str[k] = ''+form[k]
          	}
          }
        }
        var opadminname = localStorage.getItem("username")
        str['opadmin'] = opadminname
        console.log(str)
        var obj = this.obj_contact(str)
        console.log("obj=" + obj)
        modifyplayerinf(obj).then(response => {
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
      draftForm() {
//      this.getList()
        this.listLoading = true
        getyejirecord(this.postForm.uid).then(response => {
          console.log(response.data)
          this.listquan = response.data
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      getfenghaoshowtext(fenghao){
      		var text = '未封号'
      		if(fenghao == 1){
      			text = '已封号'
      		}
      		return text;
      },
     obj_contact(obj) {
        var s = ''
        for (var k in obj) {
          var v = obj[k]
          if (s == '') {
            s += k + '=' + v
          } else {
            s += '&' + k + '=' + v
          }
        }
        return s
      }
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
</style>
