package net.x52im.example.netty4.udp;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.socket.DatagramPacket;
import io.netty.util.CharsetUtil;

public class InBoundHandler extends SimpleChannelInboundHandler<byte[]> {

	@Override
	protected void channelRead0(ChannelHandlerContext ctx, byte[] msg) throws Exception {//byte[]
		// TODO Auto-generated method stub
		// 读取收到的数据
		String body = new String(msg, CharsetUtil.UTF_8);
		System.out.println("【NOTE】>>>>>> 收到客户端的数据："+body);
		
		// 回复一条信息给客户端
		String strToClient = "我是Java MINA2 Server，我的时间戳是"+System.currentTimeMillis() + "\n";
		byte[] bytesWrite = strToClient.getBytes("UTF-8");  
        ctx.channel().writeAndFlush(bytesWrite);
	}

	@Override
	public void channelActive(ChannelHandlerContext ctx) throws Exception {
		// TODO Auto-generated method stub
		super.channelActive(ctx);
		
		System.out.println("CLIENT"+getRemoteAddress(ctx)+" 接入连接");  
	}

	@Override
	public void channelInactive(ChannelHandlerContext ctx) throws Exception {
		// TODO Auto-generated method stub
		super.channelInactive(ctx);
		ctx.close();
	}

	@Override
	public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
		// TODO Auto-generated method stub
		super.userEventTriggered(ctx, evt);
		
	}

	
	public static String getIPString(ChannelHandlerContext ctx){  
        String ipString = "";  
        String socketString = ctx.channel().remoteAddress().toString();  
        int colonAt = socketString.indexOf(":");  
        ipString = socketString.substring(1, colonAt);  
        return ipString;  
    }  
      
      
    public static String getRemoteAddress(ChannelHandlerContext ctx){  
        String socketString = "";  
        socketString = ctx.channel().remoteAddress().toString();  
        return socketString;  
    }  
}
