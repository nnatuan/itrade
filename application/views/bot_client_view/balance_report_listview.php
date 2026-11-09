<form name="frm_balance_report" id="frm_balance_report" method="post" action="<?php echo $link_page; ?>">
    <div class="right_col" role="main">
        <div class="">
            <div class="clearfix"></div>

            <div class="row top_tiles qcare-top-tiles" style="margin: 10px 0;">
                <div class="animated flipInY col-lg-3 col-md-3 col-sm-6 col-xs-12">
                    <div class="tile-stats">
                        <div class="icon"><i class="fa fa-cubes text-primary"></i></div>
                        <div class="count"><?php echo number_format($bot_stats['ntotal_clients']); ?></div>
                        <h3>Tổng Tài Khoản</h3>
                        <p>Số tài khoản đăng ký sử dụng hệ thống.</p>
                    </div>
                </div>
                <div class="animated flipInY col-lg-3 col-md-3 col-sm-6 col-xs-12">
                    <div class="tile-stats">
                        <div class="icon"><i class="fa fa-check-circle text-success"></i></div>
                        <div class="count text-success"><?php echo number_format($bot_stats['nactive_bots']); ?></div>
                        <h3>Bot Trực Tuyến</h3>
                        <p>Số robot đang ở trạng thái Khởi chạy.</p>
                    </div>
                </div>
                <div class="animated flipInY col-lg-3 col-md-3 col-sm-6 col-xs-12">
                    <div class="tile-stats">
                        <div class="icon"><i class="fa fa-line-chart text-info"></i></div>
                        <div class="count text-info">$<?php echo number_format($bot_stats['ftotal_balance'], 2); ?></div>
                        <h3>Tổng Vốn Quản Lý</h3>
                        <p>Tổng số vốn (Balance) thực tế từ MT5 đẩy về.</p>
                    </div>
                </div>
                <div class="animated flipInY col-lg-3 col-md-3 col-sm-6 col-xs-12">
                    <div class="tile-stats">
                        <div class="icon"><i class="fa fa-exclamation-triangle text-danger"></i></div>
                        <div class="count text-danger"><?php echo number_format($bot_stats['nexpired_license']); ?></div>
                        <h3>License Hết Hạn</h3>
                        <p>Số lượng bản quyền đã quá hạn sử dụng.</p>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="x_panel">
                        <div class="x_title">
                            <h2><?php echo $lbl_form_title; ?></h2>
                            <ul class="nav navbar-right panel_toolbox">
                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a></li>
                            </ul>
                            <div class="clearfix"></div>
                        </div>
                        <div class="x_content">
                            
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered jambo_table bulk_action">
                                    <thead>
                                        <tr>
                                             <th class="qcare-th-center qcare-th-stt">#</th>
                                             <th class="qcare-th-code">Số tài khoản MT5</th>
                                             <th>Tên Khách hàng (Chủ tài khoản)</th>
                                             <th class="qcare-th-center">Số dư (Balance)</th>
                                             <th class="qcare-th-center">Tài sản ròng (Equity)</th>
                                             <th>Mức sụt giảm tạm thời (Drawdown)</th>
                                             <th class="qcare-th-center qcare-th-status">Trạng thái Bot</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <tr class="filter qcare-filter-row">
                                            <td class="text-center">
                                                <input name="btn_filter" type="button" class="btn btn-success btn-xs qcare-btn-filter-submit" value="Lọc" 
                                                    onclick="js_SetSubmitButtonClick(this.form, this.name);" />
                                            </td>
                                            <td> 
                                                <input name="txtf_cmt5_account" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cmt5_account) ? $txtf_cmt5_account : ''; ?>" placeholder="Tìm Số TK MT5..." />					
                                            </td>
                                            <td>
                                                <input name="txtf_cfullname" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cfullname) ? $txtf_cfullname : ''; ?>" placeholder="Tìm tên khách..." />
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td>
                                                <select name="cbof_risk_status" class="form-control input-sm" onchange="js_SetSubmitButtonClick(this.form, 'btn_filter');">
                                                    <option value="">-- Tất cả mức rủi ro --</option>
                                                    <option value="safe" <?php echo (isset($cbof_risk_status) && $cbof_risk_status == 'safe') ? 'selected' : ''; ?>>An toàn (DD < 10%)</option>
                                                    <option value="warning" <?php echo (isset($cbof_risk_status) && $cbof_risk_status == 'warning') ? 'selected' : ''; ?>>Cảnh báo (DD 10% - 30%)</option>
                                                    <option value="danger" <?php echo (isset($cbof_risk_status) && $cbof_risk_status == 'danger') ? 'selected' : ''; ?>>Nguy hiểm (DD > 30%)</option>
                                                </select>
                                            </td>
                                            <td></td>
                                        </tr> 
                                    
                                        <?php 
                                            if (isset($data_view) && is_array($data_view) && !empty($data_view)):
                                                $i = ($txt_current_page - 1) * $txt_row_per_page + 1; 
                                                foreach($data_view as $data):
                                                    $f_dd = isset($data['fdrawdown']) ? (double)$data['fdrawdown'] : 0.00;
                                                    
                                                    // Tính toán màu sắc thanh tiến trình rủi ro trực quan
                                                    $progress_cls = "progress-bar-success";
                                                    if($f_dd >= 10.00 && $f_dd < 30.00) $progress_cls = "progress-bar-warning";
                                                    elseif($f_dd >= 30.00) $progress_cls = "progress-bar-danger";
                                        ?>
                                          <tr class="even pointer">
                                             <td class="text-center"><?php echo $i; ?></td>
                                             <td><code style="color: #26b99a; font-size: 13px; font-weight: bold;"><?php echo $data['cmt5_account']; ?></code></td>
                                             <td class="text-left">
                                                <strong style="color: #4b5f71;"><?php echo Fview_text($data['cfullname']); ?></strong>
                                             </td>   
                                             <td class="text-right" style="font-weight: bold; color: #73879C; padding-right: 15px;">
                                                 $<?php echo number_format($data['fbalance'], 2); ?>
                                             </td>
                                             <td class="text-right" style="font-weight: bold; color: #1abb9c; padding-right: 15px;">
                                                 $<?php echo number_format(isset($data['fequity']) ? $data['fequity'] : $data['fbalance'], 2); ?>
                                             </td>
                                             <td>
                                                 <div style="margin-bottom: 0; margin-top: 5px;" class="progress progress_sm">
                                                     <div class="progress-bar <?php echo $progress_cls; ?>" role="progressbar" style="width: <?php echo ($f_dd > 100) ? 100 : $f_dd; ?>%;"></div>
                                                 </div>
                                                 <small style="font-weight: bold; color: #555;"><?php echo number_format($f_dd, 2); ?>% sụt giảm</small>
                                             </td>
                                             <td class="text-center">
                                                 <?php if($data['cbot_status'] == 1): ?>
                                                     <span class="label label-success" style="font-size: 11px; padding: 3px 8px;">Đang hoạt động</span>
                                                 <?php else: ?>
                                                     <span class="label label-danger" style="font-size: 11px; padding: 3px 8px;">Tạm dừng</span>
                                                 <?php endif; ?>
                                             </td>
                                          </tr>
                                        <?php 
                                                $i++; 
                                                endforeach;
                                            else: 
                                        ?>
                                          <tr>
                                             <td colspan="7" class="text-center" style="font-style: italic; color: #73879C; padding: 20px;">
                                                <i class="fa fa-info-circle"></i> Không tìm thấy dữ liệu quỹ tài chính nào trùng khớp bộ lọc rủi ro.
                                             </td>
                                          </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                            
                            <table class="table qcare-table-pagination" cellspacing="1">
                                <tr>						
                                    <td></td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">	
                                            <label class="qcare-row-per-page-label"><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;
                                            <input class="form-control text-center input-sm qcare-page-input" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>" />&nbsp;
                                            <input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>
                                    </td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">		
                                            <?php if($txt_current_page > 1): ?>
                                            <input class="btn btn-default btn-sm" name="btn_previous" type="button" value="<<" onclick="js_SetSubmitButtonClick(this.form, 'btn_previous');"/>&nbsp;	
                                            <?php endif; ?>
                                            
                                            <label class="qcare-page-indicator"><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;
                                            
                                            <?php if($txt_current_page < $txt_total_page): ?>
                                            <input class="btn btn-default btn-sm" name="btn_next" type="button" value=">>" onclick="js_SetSubmitButtonClick(this.form, 'btn_next');"/>&nbsp;
                                            <?php endif ?>
                                                    
                                            <input class="form-control text-center input-sm qcare-page-input page-num" name="txt_current_page" type="text" value="<?php echo $txt_current_page; ?>" size="5" />&nbsp;
                                                   
                                            <input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>	
                                    </td>
                                </tr>					
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <input type="hidden" name="hidden_button" id="hidden_button"/>
    <input name="hidden_nid" type="hidden" value="0" />
    <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
</form>