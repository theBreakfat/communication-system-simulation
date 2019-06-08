% �ó�����ɣ�
%   ���ɶ�������������С��������롢BPSK���ơ�
%   awgn�ŵ��������ά�ر����롢���ͳ��
%   ���յó�����ͨ��ϵͳ���ܵ�SNR����

SNRindB_seq = -1:0.5:6;%����SNR���У���λdB
symbol_error_probability = zeros(1,length(SNRindB_seq));%��������������

trellis = poly2trellis(3,[7 5 3]);%��������������ʽ�ĸ�������
vitdec_backtracking_depth = 10;%����ά�ر�����������

for i = 1:length(SNRindB_seq)
   %��������������ȵ��������С���ڵ�������ʱӦ���ø��������в��ܹ۲������
   %��ˣ��ȹ��Ƴ���ͬ���������������г��ȣ�������Ⱥܸ�ʱ����������г���
   %��������ʹ����ռ�ù�����ڴ棬���ͨ������(����Ϊbatch)ѭ����������(����
   %Ϊbn_len)�������۲�����
   [batch,bn_len] = source_len_estimate(SNRindB_seq(i));%������������г���
   symbol_error_num = 0;%�����������
   
   for j = 1:batch
      bn = randi([0,1],1,bn_len);%�����������������
      cn = convenc(bn,trellis);%���о�������
      s_t = pskmod(cn,2);%����BPSK�����γ��ѵ��ź�s_t
      
      r_t = awgn(s_t,SNRindB_seq(i),'measured');%�ѵ��ź�ͨ��awgn�ŵ��γɽ����ź�r_t
      
      rn = pskdemod(r_t,2);%�����ź�r_t����BPSK����γɶ���������rn
      rn_dec = vitdec(rn,trellis,vitdec_backtracking_depth,'trunc','hard');%���������н���ά�ر�����õ���������
      
      [number,ratio] = symerr(bn,rn_dec);%���ͳ�ƣ�numberΪ���ֵ��������
      symbol_error_num = symbol_error_num + number;%�ۼ��������
   end
   symbol_error_probability(i) = symbol_error_num/bn_len/batch;%���㵱ǰ������µ�������
   save data2 symbol_error_probability;
end
%���»�ͼ��
semilogy(SNRindB_seq,symbol_error_probability,'-b*','linewidth',1);xlabel('SNR/dB');ylabel('�������Pb');title('����������');grid on;