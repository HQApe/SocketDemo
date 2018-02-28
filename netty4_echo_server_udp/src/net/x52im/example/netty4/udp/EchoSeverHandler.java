/*
 * Copyright (C) 2016 即时通讯网(52im.net) The MobileIMSDK Project. 
 * All rights reserved.
 * Project URL:https://github.com/JackJiang2011/MobileIMSDK
 *  
 * 即时通讯网(52im.net) - 即时通讯技术社区! PROPRIETARY/CONFIDENTIAL.
 * Use is subject to license terms.
 */
package net.x52im.example.netty4.udp;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.socket.DatagramPacket;
import io.netty.util.CharsetUtil;

public class EchoSeverHandler extends SimpleChannelInboundHandler<DatagramPacket> 
{
	@Override
	protected void channelRead0(ChannelHandlerContext ctx, DatagramPacket packet)
			throws Exception
	{
		// 读取收到的数据
		ByteBuf buf = (ByteBuf) packet.copy().content();
		byte[] req = new byte[buf.readableBytes()];
		buf.readBytes(req);
		String body = new String(req, CharsetUtil.UTF_8);
		System.out.println("【NOTE】>>>>>> 收到客户端的数据："+body); 
		
		// 回复一条信息给客户端
		ctx.writeAndFlush(new DatagramPacket(
                Unpooled.copiedBuffer("我是 Java Netty4 Server，我的时间戳是"+System.currentTimeMillis()
                		, CharsetUtil.UTF_8)
                		, packet.sender())).sync();
	}

//	@Override
//	public void channelRegistered(ChannelHandlerContext ctx) throws Exception 
//	{
//		super.channelRegistered(ctx);
//		//System.out.println("I got it!");
//	}
}
