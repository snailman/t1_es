//=============================================================================
// DO NOT MODIFY THIS FILE MANUALLY!!
// THIS FILE IS GENERATED BY NETPROTO.
// IF YOU HAVE ANY QUESTIONS PLEASE CONTACT LUJIAN.
//=============================================================================

using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections.Generic;
#if !NOT_USE_FAST_STREAM
using BinaryReader = Common.FastestBinaryReader;
using BinaryWriter = Common.FastestBinaryWriter;
#endif
namespace Network.Messages
{
	
//////////////////////////////////////////////////////////////////////////
//<-发出去     ;      ->收消息
//不用使用int uint long 
//
/////////////////////////////////////////////////////////////////////////
//不用使用int uint long 
//不用使用int uint long 
//不用使用int uint long 
//不用使用int uint long 
//不用使用int uint long 
//不用使用int uint long 
	public class U2GS_Login_Normal : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_Login_Normal;

		#region members
		/// <summary>
		///  平台帐号（游戏内帐号用平台id来绑定创建）
		/// </summary>
		 public String m_platformAccount = String.Empty;
		/// <summary>
		///  平台名
		/// </summary>
		 public String m_platformName = String.Empty;
		/// <summary>
		///  平台昵称，没有就填空串
		/// </summary>
		 public String m_platformNickName = String.Empty;
		/// <summary>
		/// 
		/// </summary>
		public Int64 m_time = 0;
		/// <summary>
		/// 
		/// </summary>
		 public String m_sign = String.Empty;
		/// <summary>
		///  程序生成，每个设备不能重复
		/// </summary>
		 public String m_deviceId = String.Empty;
		/// <summary>
		///  手机串号
		/// </summary>
		 public String m_imei = String.Empty;
		/// <summary>
		///  苹果推号
		/// </summary>
		 public String m_idfa = String.Empty;
		/// <summary>
		///  网卡号
		/// </summary>
		 public String m_mac = String.Empty;
		/// <summary>
		///  扩展参数串
		/// </summary>
		 public String m_extParam = String.Empty;
		/// <summary>
		///  资源版本
		/// </summary>
		public Int32 m_versionRes = 0;
		/// <summary>
		///  执行程序版本
		/// </summary>
		public Int32 m_versionExe = 0;
		/// <summary>
		///  游戏版本？？
		/// </summary>
		public Int32 m_versionGame = 0;
		/// <summary>
		///  协议版本
		/// </summary>
		public Int32 m_versionPro = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_String( writer, m_platformAccount );
			MessageSerializer.Write_String( writer, m_platformName );
			MessageSerializer.Write_String( writer, m_platformNickName );
			MessageSerializer.Write_Int64( writer, m_time );
			MessageSerializer.Write_String( writer, m_sign );
			MessageSerializer.Write_String( writer, m_deviceId );
			MessageSerializer.Write_String( writer, m_imei );
			MessageSerializer.Write_String( writer, m_idfa );
			MessageSerializer.Write_String( writer, m_mac );
			MessageSerializer.Write_String( writer, m_extParam );
			MessageSerializer.Write_Int32( writer, m_versionRes );
			MessageSerializer.Write_Int32( writer, m_versionExe );
			MessageSerializer.Write_Int32( writer, m_versionGame );
			MessageSerializer.Write_Int32( writer, m_versionPro );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_LoginResult : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_LoginResult();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_LoginResult;

		#region members
		/// <summary>
		///  0为登录成功，非0为登录失败原因
		/// </summary>
		public SByte m_result = 0;
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_aid = 0;
		/// <summary>
		/// 
		/// </summary>
		 public String m_identity = String.Empty;
		/// <summary>
		/// 不为空，手机必须展示
		/// </summary>
		 public String m_msg = String.Empty;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_result = MessageSerializer.Read_SByte( reader );
			m_aid = MessageSerializer.Read_UInt64( reader );
			m_identity = MessageSerializer.Read_String( reader );
			m_msg = MessageSerializer.Read_String( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class UserPlayerData : SerializeAble
	{
		#region members
		/// <summary>
		///  角色ID
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		///  角色名
		/// </summary>
		 public String m_name = String.Empty;
		/// <summary>
		///  等级
		/// </summary>
		public Int32 m_level = 0;
		/// <summary>
		///  翅膀等级
		/// </summary>
		public Int32 m_wingLevel = 0;
		/// <summary>
		///  阵营
		/// </summary>
		public SByte m_camp = 0;
		/// <summary>
		///  种族
		/// </summary>
		public SByte m_race = 0;
		/// <summary>
		///  职业
		/// </summary>
		public UInt32 m_career = 0;
		/// <summary>
		///  性别
		/// </summary>
		public SByte m_sex = 0;
		/// <summary>
		///  头
		/// </summary>
		public Int32 m_head = 0;
		/// <summary>
		///  角色所在当前地图ID
		/// </summary>
		public UInt16 m_mapID = 0;
		/// <summary>
		///  角色之前所在地图ID
		/// </summary>
		public UInt16 m_oldMapID = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			MessageSerializer.Write_String( writer, m_name );
			MessageSerializer.Write_Int32( writer, m_level );
			MessageSerializer.Write_Int32( writer, m_wingLevel );
			MessageSerializer.Write_SByte( writer, m_camp );
			MessageSerializer.Write_SByte( writer, m_race );
			MessageSerializer.Write_UInt32( writer, m_career );
			MessageSerializer.Write_SByte( writer, m_sex );
			MessageSerializer.Write_Int32( writer, m_head );
			MessageSerializer.Write_UInt16( writer, m_mapID );
			MessageSerializer.Write_UInt16( writer, m_oldMapID );
			return (int)( writer.BaseStream.Position - pos );
		}
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_name = MessageSerializer.Read_String( reader );
			m_level = MessageSerializer.Read_Int32( reader );
			m_wingLevel = MessageSerializer.Read_Int32( reader );
			m_camp = MessageSerializer.Read_SByte( reader );
			m_race = MessageSerializer.Read_SByte( reader );
			m_career = MessageSerializer.Read_UInt32( reader );
			m_sex = MessageSerializer.Read_SByte( reader );
			m_head = MessageSerializer.Read_Int32( reader );
			m_mapID = MessageSerializer.Read_UInt16( reader );
			m_oldMapID = MessageSerializer.Read_UInt16( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	public partial class MessageSerializer
	{
		static public UserPlayerData Read_UserPlayerData( BinaryReader s ) {
			var ret = new UserPlayerData();
			ret.Deserialize( s );
			return ret;
		}
		static public List<UserPlayerData> ReadList_UserPlayerData( BinaryReader s ) {
			Int16 count = s.ReadInt16();
			if ( count <= 0 ) {
				return null;
			}
			var ret = new List<UserPlayerData>( count );
			for ( int i = 0; i < count; ++i ) {
				ret.Add( Read_UserPlayerData( s ) );
			}
			return ret;
		}
		static public void Write_UserPlayerData( BinaryWriter s, UserPlayerData value ) {
			value.Serialize( s );
		}
		static public void WriteList_UserPlayerData( BinaryWriter s, List<UserPlayerData> value ) {
			if ( value != null ) {
				Write_Int16( s, (Int16)value.Count );
				for ( int i = 0; i < value.Count; ++i ) {
					value[i].Serialize( s );
				}
			} else {
				Write_Int16( s, 0 );
			}
		}
	}

	
	public class GS2U_UserPlayerList : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_UserPlayerList();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_UserPlayerList;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public List<UserPlayerData> m_info = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_info = MessageSerializer.ReadList_UserPlayerData( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class U2GS_RequestCreatePlayer : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_RequestCreatePlayer;

		#region members
		/// <summary>
		///  名字
		/// </summary>
		 public String m_name = String.Empty;
		/// <summary>
		///  阵营
		/// </summary>
		public SByte m_camp = 0;
		/// <summary>
		///  职业
		/// </summary>
		public UInt32 m_career = 0;
		/// <summary>
		///  种族
		/// </summary>
		public SByte m_race = 0;
		/// <summary>
		///  性别
		/// </summary>
		public SByte m_sex = 0;
		/// <summary>
		///  头
		/// </summary>
		public Int32 m_head = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_String( writer, m_name );
			MessageSerializer.Write_SByte( writer, m_camp );
			MessageSerializer.Write_UInt32( writer, m_career );
			MessageSerializer.Write_SByte( writer, m_race );
			MessageSerializer.Write_SByte( writer, m_sex );
			MessageSerializer.Write_Int32( writer, m_head );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_CreatePlayerResult : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_CreatePlayerResult();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_CreatePlayerResult;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_errorCode = 0;
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_errorCode = MessageSerializer.Read_Int32( reader );
			m_uid = MessageSerializer.Read_UInt64( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class U2GS_SelPlayerEnterGame : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_SelPlayerEnterGame;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_SelPlayerResult : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_SelPlayerResult();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_SelPlayerResult;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_result = 0;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_result = MessageSerializer.Read_Int32( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class U2GS_RequestDeletePlayer : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_RequestDeletePlayer;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_DeletePlayerResult : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_DeletePlayerResult();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_DeletePlayerResult;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_errorCode = 0;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_errorCode = MessageSerializer.Read_Int32( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class LookInfoMonster : SerializeAble
	{
		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		///  怪物 ID	
		/// </summary>
		public UInt32 m_did = 0;
		/// <summary>
		///  怪物坐标
		/// </summary>
		public Single m_x = 0.0f;
		/// <summary>
		/// 
		/// </summary>
		public Single m_y = 0.0f;
		/// <summary>
		/// 旋转坐标W
		/// </summary>
		public Single m_rotW = 0.0f;
		/// <summary>
		///  怪物移动的目标点X
		/// </summary>
		public Single m_targetX = 0.0f;
		/// <summary>
		///  怪物移动的目标点Y
		/// </summary>
		public Single m_targetY = 0.0f;
		/// <summary>
		///  怪物移动速度
		/// </summary>
		public Single m_move_speed = 0.0f;
		/// <summary>
		///  当前血量百分比
		/// </summary>
		public Byte m_hp_per = 0;
		/// <summary>
		///  阵营
		/// </summary>
		public SByte m_camp = 0;
		/// <summary>
		///  归属
		/// </summary>
		public UInt64 m_owner = 0;
		/// <summary>
		///  怪物所属分组ID
		/// </summary>
		public UInt64 m_groupID = 0;
		/// <summary>
		///  怪物所属军团ID
		/// </summary>
		public UInt64 m_guildID = 0;
		/// <summary>
		///  名字
		/// </summary>
		 public String m_name = String.Empty;
		/// <summary>
		/// 怪物等级
		/// </summary>
		public UInt16 m_level = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			MessageSerializer.Write_UInt32( writer, m_did );
			MessageSerializer.Write_Single( writer, m_x );
			MessageSerializer.Write_Single( writer, m_y );
			MessageSerializer.Write_Single( writer, m_rotW );
			MessageSerializer.Write_Single( writer, m_targetX );
			MessageSerializer.Write_Single( writer, m_targetY );
			MessageSerializer.Write_Single( writer, m_move_speed );
			MessageSerializer.Write_Byte( writer, m_hp_per );
			MessageSerializer.Write_SByte( writer, m_camp );
			MessageSerializer.Write_UInt64( writer, m_owner );
			MessageSerializer.Write_UInt64( writer, m_groupID );
			MessageSerializer.Write_UInt64( writer, m_guildID );
			MessageSerializer.Write_String( writer, m_name );
			MessageSerializer.Write_UInt16( writer, m_level );
			return (int)( writer.BaseStream.Position - pos );
		}
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_did = MessageSerializer.Read_UInt32( reader );
			m_x = MessageSerializer.Read_Single( reader );
			m_y = MessageSerializer.Read_Single( reader );
			m_rotW = MessageSerializer.Read_Single( reader );
			m_targetX = MessageSerializer.Read_Single( reader );
			m_targetY = MessageSerializer.Read_Single( reader );
			m_move_speed = MessageSerializer.Read_Single( reader );
			m_hp_per = MessageSerializer.Read_Byte( reader );
			m_camp = MessageSerializer.Read_SByte( reader );
			m_owner = MessageSerializer.Read_UInt64( reader );
			m_groupID = MessageSerializer.Read_UInt64( reader );
			m_guildID = MessageSerializer.Read_UInt64( reader );
			m_name = MessageSerializer.Read_String( reader );
			m_level = MessageSerializer.Read_UInt16( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	public partial class MessageSerializer
	{
		static public LookInfoMonster Read_LookInfoMonster( BinaryReader s ) {
			var ret = new LookInfoMonster();
			ret.Deserialize( s );
			return ret;
		}
		static public List<LookInfoMonster> ReadList_LookInfoMonster( BinaryReader s ) {
			Int16 count = s.ReadInt16();
			if ( count <= 0 ) {
				return null;
			}
			var ret = new List<LookInfoMonster>( count );
			for ( int i = 0; i < count; ++i ) {
				ret.Add( Read_LookInfoMonster( s ) );
			}
			return ret;
		}
		static public void Write_LookInfoMonster( BinaryWriter s, LookInfoMonster value ) {
			value.Serialize( s );
		}
		static public void WriteList_LookInfoMonster( BinaryWriter s, List<LookInfoMonster> value ) {
			if ( value != null ) {
				Write_Int16( s, (Int16)value.Count );
				for ( int i = 0; i < value.Count; ++i ) {
					value[i].Serialize( s );
				}
			} else {
				Write_Int16( s, 0 );
			}
		}
	}

	
	public class GS2U_MonsterList : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_MonsterList();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_MonsterList;

		#region members
		/// <summary>
		///  视野范围内怪物列表
		/// </summary>
		public List<LookInfoMonster> m_monster_list = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_monster_list = MessageSerializer.ReadList_LookInfoMonster( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class LookInfoPlayer : SerializeAble
	{
		#region members
		/// <summary>
		/// 角色ID
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 名字
		/// </summary>
		 public String m_name = String.Empty;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_y = 0.0f;
		/// <summary>
		///  种族
		/// </summary>
		public SByte m_race = 0;
		/// <summary>
		/// 职业
		/// </summary>
		public UInt32 m_career = 0;
		/// <summary>
		///  性别
		/// </summary>
		public SByte m_sex = 0;
		/// <summary>
		/// 阵营
		/// </summary>
		public SByte m_camp = 0;
		/// <summary>
		/// 头
		/// </summary>
		public Int32 m_head = 0;
		/// <summary>
		/// 移动速度
		/// </summary>
		public Single m_move_speed = 0.0f;
		/// <summary>
		/// 当前等级	
		/// </summary>
		public Int16 m_level = 0;
		/// <summary>
		/// 当前血量百分比
		/// </summary>
		public Byte m_hp_per = 0;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			MessageSerializer.Write_String( writer, m_name );
			MessageSerializer.Write_Single( writer, m_x );
			MessageSerializer.Write_Single( writer, m_y );
			MessageSerializer.Write_SByte( writer, m_race );
			MessageSerializer.Write_UInt32( writer, m_career );
			MessageSerializer.Write_SByte( writer, m_sex );
			MessageSerializer.Write_SByte( writer, m_camp );
			MessageSerializer.Write_Int32( writer, m_head );
			MessageSerializer.Write_Single( writer, m_move_speed );
			MessageSerializer.Write_Int16( writer, m_level );
			MessageSerializer.Write_Byte( writer, m_hp_per );
			return (int)( writer.BaseStream.Position - pos );
		}
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_name = MessageSerializer.Read_String( reader );
			m_x = MessageSerializer.Read_Single( reader );
			m_y = MessageSerializer.Read_Single( reader );
			m_race = MessageSerializer.Read_SByte( reader );
			m_career = MessageSerializer.Read_UInt32( reader );
			m_sex = MessageSerializer.Read_SByte( reader );
			m_camp = MessageSerializer.Read_SByte( reader );
			m_head = MessageSerializer.Read_Int32( reader );
			m_move_speed = MessageSerializer.Read_Single( reader );
			m_level = MessageSerializer.Read_Int16( reader );
			m_hp_per = MessageSerializer.Read_Byte( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	public partial class MessageSerializer
	{
		static public LookInfoPlayer Read_LookInfoPlayer( BinaryReader s ) {
			var ret = new LookInfoPlayer();
			ret.Deserialize( s );
			return ret;
		}
		static public List<LookInfoPlayer> ReadList_LookInfoPlayer( BinaryReader s ) {
			Int16 count = s.ReadInt16();
			if ( count <= 0 ) {
				return null;
			}
			var ret = new List<LookInfoPlayer>( count );
			for ( int i = 0; i < count; ++i ) {
				ret.Add( Read_LookInfoPlayer( s ) );
			}
			return ret;
		}
		static public void Write_LookInfoPlayer( BinaryWriter s, LookInfoPlayer value ) {
			value.Serialize( s );
		}
		static public void WriteList_LookInfoPlayer( BinaryWriter s, List<LookInfoPlayer> value ) {
			if ( value != null ) {
				Write_Int16( s, (Int16)value.Count );
				for ( int i = 0; i < value.Count; ++i ) {
					value[i].Serialize( s );
				}
			} else {
				Write_Int16( s, 0 );
			}
		}
	}

	
// 玩家外观信息
	public class GS2U_LookInfoPlayer : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_LookInfoPlayer();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_LookInfoPlayer;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public List<LookInfoPlayer> m_player_list = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_player_list = MessageSerializer.ReadList_LookInfoPlayer( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
//
	public class GS2U_RemoveRemote : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_RemoveRemote();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_RemoveRemote;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public List<UInt64> m_uid_list = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid_list = MessageSerializer.ReadList_UInt64( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 切地图
	public class U2GS_ChangeMap : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_ChangeMap;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt16 m_map_id = 0;
		/// <summary>
		/// 
		/// </summary>
		public Single m_x = 0.0f;
		/// <summary>
		/// 
		/// </summary>
		public Single m_y = 0.0f;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt16( writer, m_map_id );
			MessageSerializer.Write_Single( writer, m_x );
			MessageSerializer.Write_Single( writer, m_y );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 进入地图信息
	public class GS2U_GotoNewMap : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_GotoNewMap();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_GotoNewMap;

		#region members
		/// <summary>
		///  角色所在当前地图ID
		/// </summary>
		public UInt16 m_map_id = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_y = 0.0f;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_map_id = MessageSerializer.Read_UInt16( reader );
			m_x = MessageSerializer.Read_Single( reader );
			m_y = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 请求发送初始化数据
	public class U2GS_GetPlayerInitData : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_GetPlayerInitData;

		#region members
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 测试用
	public class GS2U_PlayerInitBase : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_PlayerInitBase();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_PlayerInitBase;

		#region members
		/// <summary>
		///  角色ID
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		///  角色名
		/// </summary>
		 public String m_name = String.Empty;
		/// <summary>
		///  等级
		/// </summary>
		public Int32 m_level = 0;
		/// <summary>
		///  阵营
		/// </summary>
		public SByte m_camp = 0;
		/// <summary>
		///  种族
		/// </summary>
		public SByte m_race = 0;
		/// <summary>
		///  职业
		/// </summary>
		public UInt32 m_career = 0;
		/// <summary>
		///  性别
		/// </summary>
		public SByte m_sex = 0;
		/// <summary>
		///  头
		/// </summary>
		public Int32 m_head = 0;
		/// <summary>
		///  角色所在当前地图ID
		/// </summary>
		public UInt16 m_mapID = 0;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_name = MessageSerializer.Read_String( reader );
			m_level = MessageSerializer.Read_Int32( reader );
			m_camp = MessageSerializer.Read_SByte( reader );
			m_race = MessageSerializer.Read_SByte( reader );
			m_career = MessageSerializer.Read_UInt32( reader );
			m_sex = MessageSerializer.Read_SByte( reader );
			m_head = MessageSerializer.Read_Int32( reader );
			m_mapID = MessageSerializer.Read_UInt16( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 初始化数据发送完毕
	public class GS2U_GetPlayerInitDataEnd : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_GetPlayerInitDataEnd();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_GetPlayerInitDataEnd;

		#region members
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 行走信息
	public class ObjWalk : SerializeAble
	{
		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_src_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_src_y = 0.0f;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_dst_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_dst_y = 0.0f;
		/// <summary>
		/// 移动时间（毫秒）  
		/// </summary>
		public Int32 m_move_time = 0;
		/// <summary>
		/// 移动速度
		/// </summary>
		public Single m_speed = 0.0f;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.Write_UInt64( writer, m_uid );
			MessageSerializer.Write_Single( writer, m_src_x );
			MessageSerializer.Write_Single( writer, m_src_y );
			MessageSerializer.Write_Single( writer, m_dst_x );
			MessageSerializer.Write_Single( writer, m_dst_y );
			MessageSerializer.Write_Int32( writer, m_move_time );
			MessageSerializer.Write_Single( writer, m_speed );
			return (int)( writer.BaseStream.Position - pos );
		}
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_src_x = MessageSerializer.Read_Single( reader );
			m_src_y = MessageSerializer.Read_Single( reader );
			m_dst_x = MessageSerializer.Read_Single( reader );
			m_dst_y = MessageSerializer.Read_Single( reader );
			m_move_time = MessageSerializer.Read_Int32( reader );
			m_speed = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	public partial class MessageSerializer
	{
		static public ObjWalk Read_ObjWalk( BinaryReader s ) {
			var ret = new ObjWalk();
			ret.Deserialize( s );
			return ret;
		}
		static public List<ObjWalk> ReadList_ObjWalk( BinaryReader s ) {
			Int16 count = s.ReadInt16();
			if ( count <= 0 ) {
				return null;
			}
			var ret = new List<ObjWalk>( count );
			for ( int i = 0; i < count; ++i ) {
				ret.Add( Read_ObjWalk( s ) );
			}
			return ret;
		}
		static public void Write_ObjWalk( BinaryWriter s, ObjWalk value ) {
			value.Serialize( s );
		}
		static public void WriteList_ObjWalk( BinaryWriter s, List<ObjWalk> value ) {
			if ( value != null ) {
				Write_Int16( s, (Int16)value.Count );
				for ( int i = 0; i < value.Count; ++i ) {
					value[i].Serialize( s );
				}
			} else {
				Write_Int16( s, 0 );
			}
		}
	}

	
// 移动
	public class GS2U_SyncWalk : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_SyncWalk();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_SyncWalk;

		#region members
		/// <summary>
		/// 
		/// </summary>
		 public ObjWalk m_walk = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_walk = MessageSerializer.Read_ObjWalk( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 同步周围对象的移动信息
	public class GS2U_SyncWalkMany : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_SyncWalkMany();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_SyncWalkMany;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public List<ObjWalk> m_walks = null;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_walks = MessageSerializer.ReadList_ObjWalk( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
// 移动
	public class GS2U_SyncStand : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_SyncStand();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_SyncStand;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_cur_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_cur_y = 0.0f;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_cur_x = MessageSerializer.Read_Single( reader );
			m_cur_y = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
//
	public class U2GS_GetRemotePlayer : BaseMessage
	{
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_U2GS_GetRemotePlayer;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public List<UInt64> m_uids = null;
		#endregion

		#region methods
		public override int Serialize( BinaryWriter writer ) {
			long pos = writer.BaseStream.Position;
			MessageSerializer.WriteList_UInt64( writer, m_uids );
			return (int)( writer.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_RemotePlayer : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_RemotePlayer();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_RemotePlayer;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_level = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_cur_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_cur_y = 0.0f;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_level = MessageSerializer.Read_Int32( reader );
			m_cur_x = MessageSerializer.Read_Single( reader );
			m_cur_y = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_RemoteMonster : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_RemoteMonster();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_RemoteMonster;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 
		/// </summary>
		public UInt32 m_did = 0;
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_level = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_cur_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_cur_y = 0.0f;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_did = MessageSerializer.Read_UInt32( reader );
			m_level = MessageSerializer.Read_Int32( reader );
			m_cur_x = MessageSerializer.Read_Single( reader );
			m_cur_y = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

	
	public class GS2U_RemotePet : BaseMessage
	{
		static new public BaseMessage Create( BinaryReader s ) {
			var ret = new GS2U_RemotePet();
			ret.Deserialize( s );
			return ret;
		}
		override public MessageType GetId() {
			return ID;
		}
		public const MessageType ID = MessageType.MSG_GS2U_RemotePet;

		#region members
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_uid = 0;
		/// <summary>
		/// 
		/// </summary>
		public UInt64 m_owner = 0;
		/// <summary>
		/// 
		/// </summary>
		public UInt32 m_did = 0;
		/// <summary>
		/// 
		/// </summary>
		public Int32 m_level = 0;
		/// <summary>
		/// 坐标X
		/// </summary>
		public Single m_cur_x = 0.0f;
		/// <summary>
		/// 坐标Y
		/// </summary>
		public Single m_cur_y = 0.0f;
		#endregion

		#region methods
		public override int Deserialize( BinaryReader reader ) {
			long pos = reader.BaseStream.Position;
			m_uid = MessageSerializer.Read_UInt64( reader );
			m_owner = MessageSerializer.Read_UInt64( reader );
			m_did = MessageSerializer.Read_UInt32( reader );
			m_level = MessageSerializer.Read_Int32( reader );
			m_cur_x = MessageSerializer.Read_Single( reader );
			m_cur_y = MessageSerializer.Read_Single( reader );
			return (int)( reader.BaseStream.Position - pos );
		}
		#endregion
	}

}
//EOF