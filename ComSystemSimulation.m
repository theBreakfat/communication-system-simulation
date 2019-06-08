% 该程序完成：
%   生成二进制随机数序列、卷积码编码、BPSK调制、
%   awgn信道、解调、维特比译码、差错统计
%   最终得出评估通信系统性能的SNR曲线

SNRindB_seq = -1:0.5:6;%定义SNR序列，单位dB
symbol_error_probability = zeros(1,length(SNRindB_seq));%定义误码率序列

trellis = poly2trellis(3,[7 5 3]);%定义卷积码编码多项式的格子描述
vitdec_backtracking_depth = 10;%定义维特比译码回溯深度

for i = 1:length(SNRindB_seq)
   %误码率随着信噪比的增大而减小，在低误码率时应该用更长的序列才能观测出误码
   %因此，先估计出不同信噪比下所需的序列长度，当信噪比很高时，所需的序列长度
   %过长，会使程序占用过大的内存，因此通过多轮(轮数为batch)循环产生定长(长度
   %为bn_len)序列来观测误码
   [batch,bn_len] = source_len_estimate(SNRindB_seq(i));%估计所需的序列长度
   symbol_error_num = 0;%定义误符号数
   
   for j = 1:batch
      bn = randi([0,1],1,bn_len);%产生二进制随机序列
      cn = convenc(bn,trellis);%进行卷积码编码
      s_t = pskmod(cn,2);%进行BPSK调制形成已调信号s_t
      
      r_t = awgn(s_t,SNRindB_seq(i),'measured');%已调信号通过awgn信道形成接收信号r_t
      
      rn = pskdemod(r_t,2);%接收信号r_t进行BPSK解调形成二进制序列rn
      rn_dec = vitdec(rn,trellis,vitdec_backtracking_depth,'trunc','hard');%二进制序列进行维特比译码得到接受序列
      
      [number,ratio] = symerr(bn,rn_dec);%差错统计，number为本轮的误符号数
      symbol_error_num = symbol_error_num + number;%累计误符号数
   end
   symbol_error_probability(i) = symbol_error_num/bn_len/batch;%计算当前信噪比下的误码率
   save data2 symbol_error_probability;
end
%以下绘图：
semilogy(SNRindB_seq,symbol_error_probability,'-b*','linewidth',1);xlabel('SNR/dB');ylabel('误比特率Pb');title('误码率曲线');grid on;