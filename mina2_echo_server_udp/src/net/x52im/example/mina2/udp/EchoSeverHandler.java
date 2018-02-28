package net.x52im.example.mina2.udp;

import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;

import org.apache.mina.core.buffer.IoBuffer;
import org.apache.mina.core.future.WriteFuture;
import org.apache.mina.core.service.IoHandlerAdapter;
import org.apache.mina.core.session.IoSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class EchoSeverHandler extends IoHandlerAdapter
{
	private static Logger logger = LoggerFactory.getLogger(EchoSeverHandler.class);  
	public static final CharsetDecoder decoder = (Charset.forName("UTF-8")).newDecoder();
	public static final CharsetEncoder encoder= Charset.forName("UTF-8").newEncoder();  
	
	/**
     * MINA的异常回调方法。
     * <p>
     * 本类中将在异常发生时，立即close当前会话。
     * 
     * @param session 发生异常的会话
     * @param cause 异常内容
     * @see IoSession#close(boolean)
     */
    @Override
    public void exceptionCaught(IoSession session, Throwable cause) throws Exception 
    {
        logger.error("[IMCORE]exceptionCaught捕获到错了，原因是："+cause.getMessage(), cause);
        session.close(true);
    }
	
    /**
     * MINA框架中收到客户端消息的回调方法。
     * <p>
     * 本类将在此方法中实现完整的即时通讯数据交互和处理策略。
     * <p>
     * 为了提升并发性能，本方法将运行在独立于MINA的IoProcessor之外的线程池中，
     * 详见 {@link ServerLauncher#initAcceptor()}中的MINA设置代码 。
     * 
     * @param session 收到消息对应的会话引用
     * @param message 收到的MINA的原始消息封装对象，本类中是 {@link IoBuffer}对象
     * @throws Exception 当有错误发生时将抛出异常
     */
    @Override
    public void messageReceived(IoSession session, Object message)throws Exception 
    {
    	//*********************************************** 接收数据
    	// 读取收到的数据
    	IoBuffer buffer = (IoBuffer) message;
    	String body = buffer.getString(decoder);
    	// 注意：当客户使用不依赖于MINA库的情况下，以下官方推
    	// 荐的读取方法会在数据首部出现几个字节的未知乱码
    	// message.toString()
    	logger.debug("【NOTE】>>>>>> 收到客户端的数据："+body); 
    	
    	
    	//*********************************************** 回复数据
    	String strToClient = "我是Java MINA2 Server，我的时间戳是"+System.currentTimeMillis()+"\n";//tcp发送数据需要加上"\n"
    	byte[] res = strToClient.getBytes("UTF-8");
    	// ** （1）来自网上的组织IoBuffer数据包的方法：本方法将会错误地导致客户端UDP收到的数据多出4个字节（内容未知）
//		IoBuffer buf = IoBuffer.allocate(res.length);  
//		buf.setAutoExpand(true);  
//		buf.putInt(res.length);
//		buf.put(res);  
//		buf.flip();
//		buf.shrink();
		// ** （2）第2种组织IoBuffer数据包的方法：本方法才可以正确地让客户端UDP收到byte数组
		IoBuffer buf = IoBuffer.allocate(strToClient.length() * 8);  
		buf.putString(strToClient, encoder);
		buf.flip(); 
		// 向客户端写数据
		WriteFuture future = session.write(buf);  
		// 在100毫秒超时间内等待写完成
		future.awaitUninterruptibly(100);
		// The message has been written successfully
		if( future.isWritten() )
		{
			// send sucess!
		}
		// The messsage couldn't be written out completely for some reason.
		// (e.g. Connection is closed)
		else
		{
			logger.warn("[IMCORE]回复给客户端的数据发送失败！");
		}
    }
}
