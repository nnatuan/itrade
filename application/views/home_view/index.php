<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	$this->load->view('modules/mod_header'); 
?> 
<style>
  .qcare-card { background: #fff; border-radius: 12px; padding: 20px; margin-bottom: 20px; border: 1px solid #edf2f7; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
  .stat-box { border-radius: 12px; padding: 15px 20px; margin-bottom: 20px; }
  .stat-box h3 { margin: 5px 0; font-weight: bold; }
  .stat-box p { margin: 0; font-size: 13px; font-weight: bold; }
  .badge-active { background: #ebf3ff; color: #1e3a8a; font-weight: bold; }
  .badge-warning-custom { background: #fff6e6; color: #b45309; font-weight: bold; }
  .health-progress-label { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 13px; }
  .activity-timeline { list-style: none; padding-left: 15px; border-left: 2px solid #e2e8f0; }
  .activity-timeline li { position: relative; margin-bottom: 15px; }
  .activity-timeline li::before { content: ''; position: absolute; left: -18px; top: 4px; width: 10px; height: 10px; border-radius: 50%; background: #3b82f6; }
  .activity-timeline li.done::before { background: #10b981; }
  .activity-timeline li.warn::before { background: #f59e0b; }
  .activity-timeline li.danger::before { background: #ef4444; }
  .activity-timeline p { margin: 0; font-size: 12px; color: #64748b; }
  .flex-row-equal { display: flex; flex-wrap: wrap; }
  .flex-row-equal > div[class*="col-"] { display: flex; flex-direction: column; }
  .flex-row-equal .qcare-card { flex: 1; margin-bottom: 20px; }
</style>

<div class="right_col" role="main">
    
    <div class="row flex-row-equal">
      <div class="col-md-3 col-sm-6">
        <div class="stat-box" style="background: #e3faf5; color: #065f46;">
          <span style="font-size: 12px; font-weight: bold;">TỔNG VỐN QUẢN LÝ (BALANCE)</span>
          <h3>$<?php echo number_format($arr_stats['ftotal_balance'], 2); ?></h3>
          <p style="color: #047857;"><i class="fa fa-university"></i> Số dư thực đẩy từ MT5</p>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <div class="stat-box" style="background: #ebf3ff; color: #1e40af;">
          <span style="font-size: 12px; font-weight: bold;">BOT ĐANG KHỞI CHẠY</span>
          <h3><?php echo $arr_stats['nactive_bots']; ?></h3>
          <span class="badge badge-active">Chạy thực tế từ xa</span>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <div class="stat-box" style="background: #f2f0ff; color: #5b21b6;">
          <span style="font-size: 12px; font-weight: bold;">TỔNG TÀI SẢN THỰC (EQUITY)</span>
          <h3>$<?php echo number_format($arr_stats['ftotal_equity'], 2); ?></h3>
          <p style="color: #6d28d9;"><i class="fa fa-line-chart"></i> Sau khi trừ âm trạng thái</p>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <div class="stat-box" style="background: #fff6e6; color: #92400e;">
          <span style="font-size: 12px; font-weight: bold;">LICENSE QUÁ HẠN</span>
          <h3><?php echo $arr_stats['nexpired_license']; ?></h3>
          <span class="badge badge-warning-custom">Cần gia hạn hoặc khóa API</span>
        </div>
      </div>
    </div>

    <div class="row flex-row-equal">
      
      <div class="col-md-3 col-sm-6 col-xs-12">
        <div class="qcare-card text-center" style="height: 380px; min-height: 380px; padding: 15px;">
            <h5 style="font-weight: bold; font-size: 13px; text-transform: uppercase; text-align: left; color: #1e293b; margin-bottom: 10px;">
                Phân bổ rủi ro
            </h5>
            <div style="width: 110px; height: 110px; margin: 15px auto; position: relative;">
                <canvas id="riskDoughnutChart" width="110" height="110"></canvas>
                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
                    <h2 style="margin: 0; font-weight: bold; color: #0f766e; font-size: 22px;">
                        <?php echo $arr_stats['ntotal_clients']; ?>
                    </h2>
                    <span style="font-size: 10px; color: #64748b;">Tài khoản</span>
                </div>
            </div>
            
            <div style="margin-top: 20px; text-align: left; font-size: 12px; line-height: 1.9;">
                <div class="d-flex justify-content-between">
                    <span><i class="fa fa-circle text-success" style="font-size: 10px;"></i> An toàn (< 10%)</span>
                    <strong><?php echo $arr_stats['n_safe_count']; ?></strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span><i class="fa fa-circle text-warning" style="font-size: 10px;"></i> Cảnh báo (10%-30%)</span>
                    <strong><?php echo $arr_stats['n_warning_count']; ?></strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span><i class="fa fa-circle text-danger" style="font-size: 10px;"></i> Nguy hiểm (> 30%)</span>
                    <strong class="text-danger"><?php echo $arr_stats['n_danger_count']; ?></strong>
                </div>
            </div>
        </div>
      </div>

      <div class="col-md-3 col-sm-6 col-xs-12">
        <div class="qcare-card" style="height: 380px; min-height: 380px; overflow-y: auto; padding: 15px;">
          <h5 style="font-weight: bold; font-size: 13px; text-transform: uppercase; margin-bottom: 15px; color: #1e293b;">
            <i class="fa fa-trophy" style="color: #f1c40f;"></i> Top lợi nhuận (Profit)
          </h5>
          
          <?php 
            if(!empty($arr_top_profit)):
              foreach ($arr_top_profit as $row_pf):
                $f_pf_pct = (double)$row_pf['fprofit_percent'];
          ?>
            <div class="health-item" style="margin-top: 10px;">
              <div class="health-progress-label" style="font-size: 12px; margin-bottom: 2px; display: flex; justify-content: space-between; align-items: center;">
                <span style="max-width: 70%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<?php echo $row_pf['cmt5_account']; ?> — <?php echo Fview_text($row_pf['cfullname']); ?>">
                    <code style="font-size:11px; font-weight:bold; color:#26b99a;"><?php echo $row_pf['cmt5_account']; ?></code>
                    <span style="color: #475569; font-weight: 500;">— <?php echo Fview_text($row_pf['cfullname']); ?></span>
                </span>
                <strong style="color: #16a34a;">+<?php echo number_format($f_pf_pct, 2); ?>%</strong>
              </div>
              <div class="progress progress_sm" style="margin-bottom: 0;">
                <div class="progress-bar bg-green" role="progressbar" style="width: <?php echo ($f_pf_pct > 100) ? 100 : $f_pf_pct; ?>%;"></div>
              </div>
            </div>
          <?php 
              endforeach; 
            else:
          ?>
            <p style="font-style: italic; color: #94a3b8; margin-top: 80px; text-align: center; font-size: 12px;">
                <i class="fa fa-line-chart" style="font-size: 24px; display: block; margin-bottom: 10px; color: #cbd5e1;"></i>
                Chưa ghi nhận tài khoản phát sinh lợi nhuận dương.
            </p>
          <?php endif; ?>
        </div>
      </div>

      <div class="col-md-3 col-sm-6 col-xs-12">
        <div class="qcare-card" style="height: 380px; min-height: 380px; overflow-y: auto; padding: 15px;">
          <h5 style="font-weight: bold; font-size: 13px; text-transform: uppercase; margin-bottom: 15px; color: #1e293b;">
            <i class="fa fa-warning" style="color: #e67e22;"></i> Top gồng lỗ (Drawdown)
          </h5>
          
          <?php 
            if(!empty($arr_top_drawdown)):
              foreach ($arr_top_drawdown as $row_dd):
                $f_dd_val = (double)$row_dd['fdrawdown'];
                $bar_color = 'bg-green';
                if($f_dd_val >= 10.00 && $f_dd_val < 30.00) $bar_color = 'bg-orange';
                elseif($f_dd_val >= 30.00) $bar_color = 'bg-red';
          ?>
            <div class="health-item" style="margin-top: 10px;">
              <div class="health-progress-label" style="font-size: 12px; margin-bottom: 2px; display: flex; justify-content: space-between; align-items: center;">
                <span style="max-width: 70%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<?php echo $row_dd['cmt5_account']; ?> — <?php echo Fview_text($row_dd['cfullname']); ?>">
                    <code style="font-size:11px; font-weight:bold; color:#0f766e;"><?php echo $row_dd['cmt5_account']; ?></code>
                    <span style="color: #475569; font-weight: 500;">— <?php echo Fview_text($row_dd['cfullname']); ?></span>
                </span>
                <strong style="color: #334155;"><?php echo number_format($f_dd_val, 2); ?>%</strong>
              </div>
              <div class="progress progress_sm" style="margin-bottom: 0;">
                <div class="progress-bar <?php echo $bar_color; ?>" role="progressbar" style="width: <?php echo ($f_dd_val > 100) ? 100 : $f_dd_val; ?>%;"></div>
              </div>
            </div>
          <?php 
              endforeach; 
            else:
          ?>
            <p style="font-style: italic; color: #16a34a; margin-top: 80px; text-align: center; font-size: 12px;">
                <i class="fa fa-shield" style="font-size: 24px; display: block; margin-bottom: 10px; color: #bbf7d0;"></i>
                Tuyệt vời! Toàn bộ tài khoản hệ thống đang an toàn (0.00% DD).
            </p>
          <?php endif; ?>
        </div>
      </div>

      <div class="col-md-3 col-sm-6 col-xs-12">
        <div class="qcare-card" style="height: 380px; min-height: 380px; overflow-y: auto; padding: 15px;">
          <h5 style="font-weight: bold; font-size: 13px; text-transform: uppercase; margin-bottom: 15px; color: #1e293b;">
			  <i class="fa fa-terminal"></i> Nhật ký hoạt động
		  </h5>

		  <?php if (isset($arr_system_activities) && !empty($arr_system_activities)): ?>
            <ul class="activity-timeline" style="padding-left: 12px;">
              <?php 
                foreach ($arr_system_activities as $activity):
                  $log_cls = 'done';
                  if($activity['action'] == 'EXPIRED') $log_cls = 'danger';
                  if($activity['action'] == 'WARNING') $log_cls = 'warn';
              ?>
                <li class="<?php echo $log_cls; ?>" style="margin-bottom: 10px; padding-left: 5px;">
                  <strong style="color: #334155; font-size: 11px;"><?php echo $activity['title']; ?></strong>
                  <p style="margin: 1px 0 0 0; font-size: 10.5px; color: #64748b; line-height: 1.3;">
                    <?php echo date('H:i:s', strtotime($activity['time'])); ?> &mdash; <?php echo $activity['desc']; ?>
                  </p>
                </li>
              <?php endforeach; ?>
            </ul>
		  <?php else: ?>
            <p style="font-style: italic; color: #94a3b8; margin-top: 80px; text-align: center; font-size: 12px;">
                <i class="fa fa-code" style="font-size: 24px; display: block; margin-bottom: 10px; color: #cbd5e1;"></i>
                Chưa phát sinh nhật ký hoạt động nào.
            </p>
		  <?php endif; ?>
        </div>
      </div>

    </div>
	
	<div class="row flex-row-equal" style="margin-top: 10px;">
      <div class="col-md-12 col-sm-12">
        <div class="qcare-card">
          <div class="x_title" style="border-bottom: 2px solid #f1f5f9; padding-bottom: 10px; margin-bottom: 15px;">
            <h5 style="font-weight: bold; font-size: 14px; text-transform: uppercase; margin: 0; color: #1e293b;">
              <i class="fa fa-users" style="color: #0f766e; margin-right: 5px;"></i> Tài khoản kết nối hệ thống mới nhất
            </h5>
          </div>
          
          <div class="table-responsive">
            <table class="table table-striped jambo_table bulk_action" style="margin-bottom: 0;">
              <thead>
                <tr class="headings" style="background: #f8fafc; color: #475569;">
                  <th style="padding: 12px;">Số tài khoản MT5</th>
                  <th style="padding: 12px;">Tên Khách Hàng</th>
                  <th style="padding: 12px; text-align: right;">Số dư (Balance)</th>
                  <th style="padding: 12px; text-align: right;">Tài sản ròng (Equity)</th>
                  <th style="padding: 12px; text-align: center;">Mức sụt giảm (DD %)</th>
                  <th style="padding: 12px; text-align: center;">Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                <?php 
                  if(isset($arr_recent_clients) && !empty($arr_recent_clients)):
                    foreach($arr_recent_clients as $row_client):
                ?>
                  <tr class="even pointer" style="color: #334155;">
                    <td style="vertical-align: middle; font-weight: bold;"><code style="color: #0f766e; font-size: 13px;"><?php echo $row_client['cmt5_account']; ?></code></td>
                    <td style="vertical-align: middle; font-weight: 500;"><?php echo Fview_text($row_client['cfullname']); ?></td>
                    <td style="vertical-align: middle; text-align: right; font-weight: bold; color: #64748b;">$<?php echo number_format($row_client['fbalance'], 2); ?></td>
                    <td style="vertical-align: middle; text-align: right; font-weight: bold; color: #26b99a;">$<?php echo number_format($row_client['fequity'], 2); ?></td>
                    <td style="vertical-align: middle; text-align: center; font-weight: bold; color: <?php echo ($row_client['fdrawdown'] >= 30) ? '#ef4444' : '#334155'; ?>;">
                        <?php echo number_format($row_client['fdrawdown'], 2); ?>%
                    </td>
                    <td style="vertical-align: middle; text-align: center;">
                      <span class="badge <?php echo ($row_client['cbot_status'] == '1') ? 'badge-active' : 'badge-warning-custom'; ?>" style="font-size: 11px;">
                        <?php echo ($row_client['cbot_status'] == '1') ? 'Đang chạy' : 'Tạm dừng'; ?>
                      </span>
                    </td>
                  </tr>
                <?php 
                    endforeach;
                  else:
                ?>
                  <tr><td colspan="6" style="text-align: center; padding: 20px; color: #64748b;"><i class="fa fa-info-circle"></i> Hệ thống chưa ghi nhận tài khoản kết nối nào.</td></tr>
                <?php endif; ?>
              </tbody>
            </table>
          </div>
          
        </div>
      </div>
    </div>
</div>

<?php
	$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>