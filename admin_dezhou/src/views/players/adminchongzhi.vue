<template>
  <div class="app-container calendar-list-container">



    <el-table :data="list" v-loading.body="listLoading" border fit highlight-current-row style="width: 100%">


      <el-table-column align="center" label="玩家账号" >
        <template slot-scope="scope">
          <span>{{scope.row.uid}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家昵称" >
        <template slot-scope="scope">
          <span>{{scope.row.name}}</span>
        </template>
      </el-table-column>

      <el-table-column align="center" label="玩家ID" >
        <template slot-scope="scope">
          <span>{{scope.row.uid2}}</span>
        </template>
      </el-table-column>


      <el-table-column align="center" label="充值数量" >
        <template slot-scope="scope">
          <span>{{scope.row.coin}}</span>
        </template>
      </el-table-column>


      <el-table-column min-width="80px" align="center" label="充值时间">
        <template slot-scope="scope">
          <span>{{getTime(scope.row.time)}}</span>
        </template>
      </el-table-column>
      

    </el-table>

    <div v-show="!listLoading" class="pagination-container">
      <el-pagination background @size-change="handleSizeChange" @current-change="handleCurrentChange" :current-page.sync="listQuery.page"
                     :page-sizes="[10,20,30, 50]" :page-size="listQuery.limit" layout="total, sizes, prev, pager, next, jumper" :total="total">
      </el-pagination>
    </div>


    <el-dialog :title="textMap" :visible.sync="dialogFormVisible">
      <el-form :model="temp" label-position="left" label-width="70px" style='width: 550px; margin-left:50px;'>
        <el-input type="textarea" placeholder="Please input" v-model="temp.remark">
        </el-input>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取消</el-button>

        <el-button type="primary" >确定</el-button>
      </div>
    </el-dialog>

  </div>
</template>

<script>
  import { getadminaddcoin } from '@/api/players'
  const defaultForm = {
    uid: ''
  }
  export default {
    name: 'inlineEditTable',
    data() {
      return {
        postForm: Object.assign({}, defaultForm),
        list: null,
        listquan: null,
        listLoading: true,
        total: null,
        listQuery: {
          page: 1,
          limit: 10
        },
        textMap: '请输入理由',
        dialogFormVisible: false,
        dialogStatus: '',
        temp: {
          id: undefined,
          importance: 1,
          remark: '',
          timestamp: new Date(),
          title: '',
          type: '',
          status: 'published'
        },
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
      handleModifyStatus() {
        this.$message({
          message: '操作成功',
          type: 'success'
        })
      },
      getList() {
        this.listLoading = true
        getadminaddcoin(this.postForm.uid).then(response => {
          console.log(response.data)
          if (JSON.stringify(response.data) == "{}"){
            this.listquan = []
          } else {
            this.listquan = response.data
          }
          this.total = response.data.length
          this.list = this.listquan.slice(0, this.listQuery.limit)
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
