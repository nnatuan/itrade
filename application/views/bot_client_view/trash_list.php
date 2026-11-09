<div class="right_col" role="main">
    <div class="">
        <div class="page-title">
            <div class="title_left">
                <h3><i class="fa fa-trash-o"></i> <?php echo $lbl_title; ?></h3>
            </div>
            <div class="title_right text-right">
                <a href="<?php echo $link_back; ?>" class="btn btn-secondary"><i class="fa fa-arrow-left"></i> Quay lại danh sách chính</a>
            </div>
        </div>
        <div class="clearfix"></div>

        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="x_panel">
                    <div class="x_content">
                        <div class="table-responsive">
                            <table class="table table-striped table-bordered jambo_table bulk_action">
                                <thead>
                                    <tr class="headings">
                                        <th class="column-title text-center" style="width: 50px;">STT</th>
                                        <th class="column-title">Tên đăng nhập</th>
                                        <th class="column-title">Họ tên khách</th>
                                        <th class="column-title text-center">Số TK MT5</th>
                                        <th class="column-title text-center">Sàn Trade</th>
                                        <th class="column-title text-center">Bản Bot</th>
                                        <th class="column-title">License Key</th>
                                        <th class="column-title text-center" style="width: 172px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php if (!empty($list_trash)): ?>
                                        <?php $stt = 1; foreach ($list_trash as $row): ?>
                                            <tr>
                                                <td class="text-center"><?php echo $stt++; ?></td>
                                                <td><strong><?php echo htmlspecialchars($row['cuserid']); ?></strong></td>
                                                <td><?php echo htmlspecialchars($row['cfullname']); ?></td>
                                                <td class="text-center font-weight-bold text-primary"><?php echo $row['cmt5_account']; ?></td>
                                                <td class="text-center"><?php echo htmlspecialchars($row['cbroker_name']); ?></td>
                                                <td class="text-center"><span class="badge badge-info"><?php echo $row['cbot_version']; ?></span></td>
                                                <td><code><?php echo $row['clicense_key']; ?></code></td>
                                                <td class="text-center">
                                                    <a href="javascript:void(0);" 
                                                       onclick="confirmHardDelete('<?php echo $link_action . $row['nid']; ?>', '<?php echo $row['cmt5_account']; ?>');" 
                                                       class="btn btn-danger btn-xs" 
                                                       title="Xóa hoàn toàn khỏi CSDL">
                                                        <i class="fa fa-times"></i> Xóa vĩnh viễn
                                                    </a>
                                                </td>
                                            </tr>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <tr>
                                            <td colspan="8" class="text-center py-4 text-muted">
                                                <i class="fa fa-folder-open-o fa-2x"></i><br>Không có tài khoản nào trong thùng rác.
                                            </td>
                                        </tr>
                                    <?php endif; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
function confirmHardDelete(deleteUrl, accountNo) {
    var msg = "CẢNH BÁO:\n\nBạn có chắc chắn muốn XÓA VĨNH VIỄN tài khoản MT5 [" + accountNo + "] khỏi cơ sở dữ liệu không?\n\nDữ liệu cấu hình bot và lịch sử license liên quan sẽ mất hoàn toàn và KHÔNG THỂ khôi phục lại!";
    if (confirm(msg)) {
        window.location.href = deleteUrl;
    }
}
</script>