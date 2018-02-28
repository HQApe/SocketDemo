package net.x52im.example.netty4.udp;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelOutboundHandlerAdapter;
import io.netty.channel.ChannelPromise;
import io.netty.util.CharsetUtil;

public class OutBoundHandler extends ChannelOutboundHandlerAdapter {

	@Override
	public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) throws Exception {
		// TODO Auto-generated method stub
//		super.write(ctx, msg, promise);
		
		if (msg instanceof byte[]) {  
            byte[] bytesWrite = (byte[])msg;  
            ByteBuf buf = ctx.alloc().buffer(bytesWrite.length);   
            buf.writeBytes(bytesWrite);  
            System.out.println("向设备下发的信息为："+ new String(bytesWrite, CharsetUtil.UTF_8));
            
            ctx.writeAndFlush(buf).addListener(new ChannelFutureListener(){    
                @Override    
                public void operationComplete(ChannelFuture future)    
                        throws Exception {    
                	System.out.println("下发成功！");  
                }    
            });  
        }  
	}
}
