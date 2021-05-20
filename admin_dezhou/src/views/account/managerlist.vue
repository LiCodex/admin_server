<template>


  <div class="app-container calendar-list-container">

    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">
    	
      <el-table-column align="center" label="代理ID">
        <template slot-scope="scope">
          <span>{{parseInt(scope.row.uid)}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="代理名称">
        <template slot-scope="scope">
          <span>{{scope.row.name}}</span>
        </template>
      </el-table-column>
      <!--<el-table-column align="center" label="密码">
        <template slot-scope="scope">
          <span>{{scope.row.password}}</span>
        </template>
      </el-table-column>
      <el-table-column align="center" label="权限">
        <template slot-scope="scope">
          <span>{{scope.row.role}}</span>
        </template>
      </el-table-column>-->
      <!--<el-table-column align="center" label="添加时间">
        <template slot-scope="scope">
          <span>{{getTime(parseInt(scope.row.timestamp))}}</span>
        </template>
      </el-table-column>-->

      <!--<el-table-column min-width="100px" align="center" label="操作">
        <template slot-scope="scope">
          <el-button  type="success"  @click="deletemanager(scope.row.uid)">删除管理员</el-button>          
        </template>
      </el-table-column>-->
      
    </el-table>
    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>

  </div>
</template>

<script>
  import { managerlist ,delmanager,daililist } from '@/api/manager'
  const defaultForm = {
    uid: '',
    start_time: undefined, // 前台展示时间
    end_time: undefined // 前台展示时间
  }

  export default {
    name: 'inlineEditTable',
    data() {
      return {
      	dialogFormVisible: false,
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
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        daililist(this.postForm.uid).then(response => {
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
      deletemanager(uid) {
        this.listLoading = true        
        delmanager(uid).then(response => {
          this.handleModifyStatus()
          this.daililist()
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
        getplayers(this.postForm.uid).then(response => {
          console.log(response.data)
          this.listquan = response.data
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
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
</style>
