local obf_stringchar = string.char;
local obf_stringbyte = string.byte;
local obf_stringsub = string.sub;
local obf_bitlib = bit32 or bit;
local obf_XOR = obf_bitlib.bxor;
local obf_tableconcat = table.concat;
local obf_tableinsert = table.insert;
local function LUAOBFUSACTOR_DECRYPT_STR_0(LUAOBFUSACTOR_STR, LUAOBFUSACTOR_KEY)
	local result = {};
	for i = 1, #LUAOBFUSACTOR_STR do
		obf_tableinsert(result, obf_stringchar(obf_XOR(obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_STR, i, i + 1)), obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_KEY, 1 + (i % #LUAOBFUSACTOR_KEY), 1 + (i % #LUAOBFUSACTOR_KEY) + 1))) % 256));
	end
	return obf_tableconcat(result);
end
local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), LUAOBFUSACTOR_DECRYPT_STR_0("\159\141", "\126\177\163\187\69\134\219\167"), function(byte)
		if (Byte(byte, 2) == 81) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_76979 = 0;
				local b;
				while true do
					if (FlatIdent_76979 == 1) then
						return b;
					end
					if (FlatIdent_76979 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_76979 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_24A02 = 0;
			local Res;
			while true do
				if (FlatIdent_24A02 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_7126A = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_7126A == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_7126A == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_7126A = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_6E04E = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_6E04E == 3) then
				return Concat(FStr);
			end
			if (0 == FlatIdent_6E04E) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_6E04E = 1;
			end
			if (2 == FlatIdent_6E04E) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_6E04E = 3;
			end
			if (1 == FlatIdent_6E04E) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_6E04E = 2;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_7366E = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_7366E == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (0 == FlatIdent_7366E) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_7366E = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_7DD24 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_7DD24 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_781F8 = 0;
							while true do
								if (FlatIdent_781F8 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_29127 = 0;
				while true do
					if (FlatIdent_29127 == 1) then
						if (Enum <= 143) then
							if (Enum <= 71) then
								if (Enum <= 35) then
									if (Enum <= 17) then
										if (Enum <= 8) then
											if (Enum <= 3) then
												if (Enum <= 1) then
													if (Enum > 0) then
														local FlatIdent_61B23 = 0;
														local B;
														local A;
														while true do
															if (FlatIdent_61B23 == 3) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																FlatIdent_61B23 = 4;
															end
															if (FlatIdent_61B23 == 11) then
																A = Inst[2];
																B = Stk[Inst[3]];
																Stk[A + 1] = B;
																Stk[A] = B[Inst[4]];
																break;
															end
															if (FlatIdent_61B23 == 5) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Env[Inst[3]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																FlatIdent_61B23 = 6;
															end
															if (FlatIdent_61B23 == 9) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																A = Inst[2];
																FlatIdent_61B23 = 10;
															end
															if (FlatIdent_61B23 == 7) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = {};
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																FlatIdent_61B23 = 8;
															end
															if (FlatIdent_61B23 == 6) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Upvalues[Inst[3]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																FlatIdent_61B23 = 7;
															end
															if (FlatIdent_61B23 == 0) then
																B = nil;
																A = nil;
																Stk[Inst[2]] = Env[Inst[3]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																FlatIdent_61B23 = 1;
															end
															if (FlatIdent_61B23 == 8) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																FlatIdent_61B23 = 9;
															end
															if (FlatIdent_61B23 == 10) then
																Stk[A](Unpack(Stk, A + 1, Inst[3]));
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																FlatIdent_61B23 = 11;
															end
															if (2 == FlatIdent_61B23) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Inst[4];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Env[Inst[3]];
																FlatIdent_61B23 = 3;
															end
															if (FlatIdent_61B23 == 1) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																FlatIdent_61B23 = 2;
															end
															if (FlatIdent_61B23 == 4) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]][Inst[3]] = Inst[4];
																FlatIdent_61B23 = 5;
															end
														end
													else
														local A = Inst[2];
														local Results, Limit = _R(Stk[A](Stk[A + 1]));
														Top = (Limit + A) - 1;
														local Edx = 0;
														for Idx = A, Top do
															local FlatIdent_74348 = 0;
															while true do
																if (FlatIdent_74348 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
													end
												elseif (Enum == 2) then
													local FlatIdent_759F1 = 0;
													local A;
													while true do
														if (FlatIdent_759F1 == 7) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (FlatIdent_759F1 == 1) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_759F1 = 2;
														end
														if (FlatIdent_759F1 == 2) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_759F1 = 3;
														end
														if (FlatIdent_759F1 == 5) then
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_759F1 = 6;
														end
														if (FlatIdent_759F1 == 0) then
															A = nil;
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_759F1 = 1;
														end
														if (FlatIdent_759F1 == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															FlatIdent_759F1 = 5;
														end
														if (FlatIdent_759F1 == 6) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_759F1 = 7;
														end
														if (FlatIdent_759F1 == 3) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_759F1 = 4;
														end
													end
												else
													Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
												end
											elseif (Enum <= 5) then
												if (Enum == 4) then
													Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
												else
													local FlatIdent_6DC53 = 0;
													local B;
													local A;
													while true do
														if (FlatIdent_6DC53 == 6) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_6DC53 = 7;
														end
														if (FlatIdent_6DC53 == 9) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															do
																return;
															end
															break;
														end
														if (FlatIdent_6DC53 == 4) then
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6DC53 = 5;
														end
														if (FlatIdent_6DC53 == 1) then
															Stk[A](Stk[A + 1]);
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6DC53 = 2;
														end
														if (FlatIdent_6DC53 == 8) then
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A](Stk[A + 1]);
															FlatIdent_6DC53 = 9;
														end
														if (5 == FlatIdent_6DC53) then
															A = Inst[2];
															Stk[A](Stk[A + 1]);
															VIP = VIP + 1;
															FlatIdent_6DC53 = 6;
														end
														if (FlatIdent_6DC53 == 7) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_6DC53 = 8;
														end
														if (FlatIdent_6DC53 == 3) then
															A = Inst[2];
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															FlatIdent_6DC53 = 4;
														end
														if (FlatIdent_6DC53 == 2) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6DC53 = 3;
														end
														if (0 == FlatIdent_6DC53) then
															B = nil;
															A = nil;
															A = Inst[2];
															FlatIdent_6DC53 = 1;
														end
													end
												end
											elseif (Enum <= 6) then
												Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											elseif (Enum == 7) then
												local FlatIdent_45D37 = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_45D37 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_45D37 = 5;
													end
													if (FlatIdent_45D37 == 13) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_45D37 = 14;
													end
													if (FlatIdent_45D37 == 7) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_45D37 = 8;
													end
													if (FlatIdent_45D37 == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 1;
													end
													if (FlatIdent_45D37 == 1) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 2;
													end
													if (FlatIdent_45D37 == 12) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 13;
													end
													if (FlatIdent_45D37 == 18) then
														for Idx = A, Top do
															local FlatIdent_912A7 = 0;
															while true do
																if (FlatIdent_912A7 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 19;
													end
													if (FlatIdent_45D37 == 15) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_45D37 = 16;
													end
													if (FlatIdent_45D37 == 2) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_45D37 = 3;
													end
													if (FlatIdent_45D37 == 22) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_8B272 = 0;
															while true do
																if (0 == FlatIdent_8B272) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (FlatIdent_45D37 == 19) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_45D37 = 20;
													end
													if (FlatIdent_45D37 == 16) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 17;
													end
													if (FlatIdent_45D37 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_45D37 = 6;
													end
													if (FlatIdent_45D37 == 9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_45D37 = 10;
													end
													if (FlatIdent_45D37 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_45D37 = 11;
													end
													if (FlatIdent_45D37 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_45D37 = 4;
													end
													if (FlatIdent_45D37 == 11) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 12;
													end
													if (FlatIdent_45D37 == 20) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_45D37 = 21;
													end
													if (FlatIdent_45D37 == 8) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_45D37 = 9;
													end
													if (FlatIdent_45D37 == 21) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_69C4C = 0;
															while true do
																if (FlatIdent_69C4C == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
														FlatIdent_45D37 = 22;
													end
													if (FlatIdent_45D37 == 17) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_45D37 = 18;
													end
													if (FlatIdent_45D37 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D37 = 7;
													end
													if (FlatIdent_45D37 == 14) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														FlatIdent_45D37 = 15;
													end
												end
											else
												local A = Inst[2];
												local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
												Top = (Limit + A) - 1;
												local Edx = 0;
												for Idx = A, Top do
													local FlatIdent_3F7F4 = 0;
													while true do
														if (0 == FlatIdent_3F7F4) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
											end
										elseif (Enum <= 12) then
											if (Enum <= 10) then
												if (Enum > 9) then
													local FlatIdent_43626 = 0;
													local A;
													while true do
														if (0 == FlatIdent_43626) then
															A = Inst[2];
															Stk[A] = Stk[A](Stk[A + 1]);
															break;
														end
													end
												else
													local FlatIdent_43337 = 0;
													while true do
														if (FlatIdent_43337 == 3) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															FlatIdent_43337 = 4;
														end
														if (FlatIdent_43337 == 5) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_43337 = 6;
														end
														if (FlatIdent_43337 == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_43337 = 5;
														end
														if (6 == FlatIdent_43337) then
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_43337 = 7;
														end
														if (FlatIdent_43337 == 0) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = not Stk[Inst[3]];
															FlatIdent_43337 = 1;
														end
														if (FlatIdent_43337 == 1) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Upvalues[Inst[3]] = Stk[Inst[2]];
															VIP = VIP + 1;
															FlatIdent_43337 = 2;
														end
														if (FlatIdent_43337 == 2) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_43337 = 3;
														end
														if (FlatIdent_43337 == 7) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
													end
												end
											elseif (Enum > 11) then
												local FlatIdent_829F9 = 0;
												local A;
												while true do
													if (FlatIdent_829F9 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_829F9 = 9;
													end
													if (FlatIdent_829F9 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_829F9 = 5;
													end
													if (FlatIdent_829F9 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_829F9 = 2;
													end
													if (FlatIdent_829F9 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_829F9 = 3;
													end
													if (FlatIdent_829F9 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_829F9 = 6;
													end
													if (FlatIdent_829F9 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														FlatIdent_829F9 = 4;
													end
													if (6 == FlatIdent_829F9) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_829F9 = 7;
													end
													if (FlatIdent_829F9 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_829F9 = 1;
													end
													if (FlatIdent_829F9 == 9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_829F9 == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_829F9 = 8;
													end
												end
											else
												local FlatIdent_1BA2F = 0;
												local A;
												while true do
													if (FlatIdent_1BA2F == 0) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														break;
													end
												end
											end
										elseif (Enum <= 14) then
											if (Enum == 13) then
												local FlatIdent_69F0 = 0;
												while true do
													if (FlatIdent_69F0 == 0) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_69F0 = 1;
													end
													if (FlatIdent_69F0 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69F0 = 3;
													end
													if (3 == FlatIdent_69F0) then
														if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (1 == FlatIdent_69F0) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_69F0 = 2;
													end
												end
											else
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
											end
										elseif (Enum <= 15) then
											local K;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										elseif (Enum > 16) then
											local FlatIdent_1512 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_1512 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_1512 = 7;
												end
												if (FlatIdent_1512 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_1512 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1512 = 4;
												end
												if (FlatIdent_1512 == 2) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1512 = 3;
												end
												if (FlatIdent_1512 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_1512 = 5;
												end
												if (FlatIdent_1512 == 7) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1512 = 8;
												end
												if (FlatIdent_1512 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1512 = 1;
												end
												if (FlatIdent_1512 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1512 = 6;
												end
												if (1 == FlatIdent_1512) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1512 = 2;
												end
											end
										else
											local Edx;
											local Results, Limit;
											local A;
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_43BF7 = 0;
												while true do
													if (0 == FlatIdent_43BF7) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum <= 26) then
										if (Enum <= 21) then
											if (Enum <= 19) then
												if (Enum > 18) then
													local B;
													local T;
													local A;
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													T = Stk[A];
													B = Inst[3];
													for Idx = 1, B do
														T[Idx] = Stk[A + Idx];
													end
												else
													local FlatIdent_6E214 = 0;
													local A;
													while true do
														if (FlatIdent_6E214 == 11) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
															FlatIdent_6E214 = 12;
														end
														if (FlatIdent_6E214 == 12) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															FlatIdent_6E214 = 13;
														end
														if (FlatIdent_6E214 == 7) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_6E214 = 8;
														end
														if (2 == FlatIdent_6E214) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
															VIP = VIP + 1;
															FlatIdent_6E214 = 3;
														end
														if (9 == FlatIdent_6E214) then
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															FlatIdent_6E214 = 10;
														end
														if (0 == FlatIdent_6E214) then
															A = nil;
															Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6E214 = 1;
														end
														if (FlatIdent_6E214 == 5) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_6E214 = 6;
														end
														if (FlatIdent_6E214 == 6) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6E214 = 7;
														end
														if (FlatIdent_6E214 == 1) then
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_6E214 = 2;
														end
														if (FlatIdent_6E214 == 8) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_6E214 = 9;
														end
														if (FlatIdent_6E214 == 10) then
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6E214 = 11;
														end
														if (3 == FlatIdent_6E214) then
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_6E214 = 4;
														end
														if (FlatIdent_6E214 == 13) then
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (FlatIdent_6E214 == 4) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
															FlatIdent_6E214 = 5;
														end
													end
												end
											elseif (Enum > 20) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
											else
												local FlatIdent_58F5E = 0;
												local A;
												while true do
													if (FlatIdent_58F5E == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_58F5E = 14;
													end
													if (FlatIdent_58F5E == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_58F5E = 3;
													end
													if (FlatIdent_58F5E == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_58F5E = 11;
													end
													if (FlatIdent_58F5E == 7) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_58F5E = 8;
													end
													if (5 == FlatIdent_58F5E) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_58F5E = 6;
													end
													if (FlatIdent_58F5E == 12) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_58F5E = 13;
													end
													if (FlatIdent_58F5E == 14) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_58F5E = 15;
													end
													if (FlatIdent_58F5E == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_58F5E = 4;
													end
													if (FlatIdent_58F5E == 8) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_58F5E = 9;
													end
													if (FlatIdent_58F5E == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_58F5E = 10;
													end
													if (FlatIdent_58F5E == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_58F5E = 5;
													end
													if (FlatIdent_58F5E == 15) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_58F5E == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_58F5E = 12;
													end
													if (FlatIdent_58F5E == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_58F5E = 2;
													end
													if (FlatIdent_58F5E == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_58F5E = 1;
													end
													if (FlatIdent_58F5E == 6) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_58F5E = 7;
													end
												end
											end
										elseif (Enum <= 23) then
											if (Enum == 22) then
												local FlatIdent_8A8EC = 0;
												local B;
												local T;
												local A;
												while true do
													if (FlatIdent_8A8EC == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8A8EC = 6;
													end
													if (FlatIdent_8A8EC == 0) then
														B = nil;
														T = nil;
														A = nil;
														FlatIdent_8A8EC = 1;
													end
													if (FlatIdent_8A8EC == 6) then
														Inst = Instr[VIP];
														A = Inst[2];
														T = Stk[A];
														FlatIdent_8A8EC = 7;
													end
													if (FlatIdent_8A8EC == 7) then
														B = Inst[3];
														for Idx = 1, B do
															T[Idx] = Stk[A + Idx];
														end
														break;
													end
													if (FlatIdent_8A8EC == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8A8EC = 4;
													end
													if (FlatIdent_8A8EC == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8A8EC = 5;
													end
													if (FlatIdent_8A8EC == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														FlatIdent_8A8EC = 3;
													end
													if (FlatIdent_8A8EC == 1) then
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														FlatIdent_8A8EC = 2;
													end
												end
											else
												local FlatIdent_2DF14 = 0;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_2DF14 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_2DF14 = 6;
													end
													if (FlatIdent_2DF14 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_2DF14 = 2;
													end
													if (FlatIdent_2DF14 == 4) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_2DF14 = 5;
													end
													if (FlatIdent_2DF14 == 7) then
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														break;
													end
													if (FlatIdent_2DF14 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2DF14 = 7;
													end
													if (FlatIdent_2DF14 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														FlatIdent_2DF14 = 3;
													end
													if (FlatIdent_2DF14 == 0) then
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_2DF14 = 1;
													end
													if (3 == FlatIdent_2DF14) then
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_91A09 = 0;
															while true do
																if (FlatIdent_91A09 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_2DF14 = 4;
													end
												end
											end
										elseif (Enum <= 24) then
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										elseif (Enum > 25) then
											local FlatIdent_2C74 = 0;
											local A;
											while true do
												if (FlatIdent_2C74 == 0) then
													A = nil;
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_2C74 = 1;
												end
												if (FlatIdent_2C74 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2C74 = 2;
												end
												if (FlatIdent_2C74 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_2C74 = 3;
												end
												if (4 == FlatIdent_2C74) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_2C74 = 5;
												end
												if (FlatIdent_2C74 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2C74 = 4;
												end
												if (FlatIdent_2C74 == 5) then
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
											end
										else
											local FlatIdent_77CC3 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_77CC3 == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_77CC3 = 3;
												end
												if (FlatIdent_77CC3 == 6) then
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (0 == FlatIdent_77CC3) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_77CC3 = 1;
												end
												if (FlatIdent_77CC3 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_77CC3 = 4;
												end
												if (4 == FlatIdent_77CC3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_77CC3 = 5;
												end
												if (5 == FlatIdent_77CC3) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_77CC3 = 6;
												end
												if (FlatIdent_77CC3 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_77CC3 = 2;
												end
											end
										end
									elseif (Enum <= 30) then
										if (Enum <= 28) then
											if (Enum == 27) then
												local FlatIdent_1F138 = 0;
												local A;
												while true do
													if (FlatIdent_1F138 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
														FlatIdent_1F138 = 3;
													end
													if (FlatIdent_1F138 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_1F138 = 4;
													end
													if (FlatIdent_1F138 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1F138 = 5;
													end
													if (5 == FlatIdent_1F138) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1F138 = 6;
													end
													if (FlatIdent_1F138 == 0) then
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_1F138 = 1;
													end
													if (FlatIdent_1F138 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A]();
														FlatIdent_1F138 = 2;
													end
													if (6 == FlatIdent_1F138) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
												end
											else
												local FlatIdent_69CF9 = 0;
												while true do
													if (FlatIdent_69CF9 == 0) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69CF9 = 1;
													end
													if (FlatIdent_69CF9 == 4) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69CF9 = 5;
													end
													if (FlatIdent_69CF9 == 2) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69CF9 = 3;
													end
													if (FlatIdent_69CF9 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69CF9 = 4;
													end
													if (FlatIdent_69CF9 == 5) then
														do
															return;
														end
														break;
													end
													if (FlatIdent_69CF9 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_69CF9 = 2;
													end
												end
											end
										elseif (Enum == 29) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] <= Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local FlatIdent_4C5EF = 0;
											local A;
											while true do
												if (FlatIdent_4C5EF == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4C5EF = 1;
												end
												if (FlatIdent_4C5EF == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_4C5EF == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_4C5EF = 2;
												end
												if (FlatIdent_4C5EF == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_4C5EF = 3;
												end
												if (4 == FlatIdent_4C5EF) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_4C5EF = 5;
												end
												if (FlatIdent_4C5EF == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_4C5EF = 4;
												end
											end
										end
									elseif (Enum <= 32) then
										if (Enum > 31) then
											local FlatIdent_851CE = 0;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_851CE == 14) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_851CE = 15;
												end
												if (FlatIdent_851CE == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_851CE = 5;
												end
												if (FlatIdent_851CE == 25) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 26;
												end
												if (FlatIdent_851CE == 26) then
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_851CE == 12) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 13;
												end
												if (FlatIdent_851CE == 22) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_851CE = 23;
												end
												if (7 == FlatIdent_851CE) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_851CE = 8;
												end
												if (FlatIdent_851CE == 24) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_851CE = 25;
												end
												if (FlatIdent_851CE == 15) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													FlatIdent_851CE = 16;
												end
												if (FlatIdent_851CE == 17) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_851CE = 18;
												end
												if (FlatIdent_851CE == 20) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_851CE = 21;
												end
												if (2 == FlatIdent_851CE) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_851CE = 3;
												end
												if (FlatIdent_851CE == 0) then
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_851CE = 1;
												end
												if (FlatIdent_851CE == 9) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_851CE = 10;
												end
												if (FlatIdent_851CE == 16) then
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_54124 = 0;
														while true do
															if (FlatIdent_54124 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 17;
												end
												if (11 == FlatIdent_851CE) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_851CE = 12;
												end
												if (FlatIdent_851CE == 18) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													FlatIdent_851CE = 19;
												end
												if (FlatIdent_851CE == 23) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 24;
												end
												if (FlatIdent_851CE == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 11;
												end
												if (FlatIdent_851CE == 13) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_851CE = 14;
												end
												if (FlatIdent_851CE == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 2;
												end
												if (FlatIdent_851CE == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_851CE = 4;
												end
												if (FlatIdent_851CE == 21) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_851CE = 22;
												end
												if (FlatIdent_851CE == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 7;
												end
												if (FlatIdent_851CE == 19) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_851CE = 20;
												end
												if (5 == FlatIdent_851CE) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_851CE = 6;
												end
												if (FlatIdent_851CE == 8) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													FlatIdent_851CE = 9;
												end
											end
										else
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
										end
									elseif (Enum <= 33) then
										local FlatIdent_68E5B = 0;
										while true do
											if (FlatIdent_68E5B == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_68E5B = 3;
											end
											if (0 == FlatIdent_68E5B) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_68E5B = 1;
											end
											if (FlatIdent_68E5B == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_68E5B = 2;
											end
											if (3 == FlatIdent_68E5B) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
										end
									elseif (Enum > 34) then
										local B;
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local FlatIdent_44652 = 0;
										while true do
											if (FlatIdent_44652 == 4) then
												Stk[Inst[2]] = Env[Inst[3]];
												break;
											end
											if (FlatIdent_44652 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_44652 = 4;
											end
											if (FlatIdent_44652 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_44652 = 3;
											end
											if (FlatIdent_44652 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_44652 = 2;
											end
											if (FlatIdent_44652 == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_44652 = 1;
											end
										end
									end
								elseif (Enum <= 53) then
									if (Enum <= 44) then
										if (Enum <= 39) then
											if (Enum <= 37) then
												if (Enum > 36) then
													local FlatIdent_41ABD = 0;
													local B;
													local A;
													while true do
														if (FlatIdent_41ABD == 2) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															FlatIdent_41ABD = 3;
														end
														if (FlatIdent_41ABD == 0) then
															B = nil;
															A = nil;
															Upvalues[Inst[3]] = Stk[Inst[2]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_41ABD = 1;
														end
														if (FlatIdent_41ABD == 8) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_41ABD = 9;
														end
														if (FlatIdent_41ABD == 7) then
															Inst = Instr[VIP];
															for Idx = Inst[2], Inst[3] do
																Stk[Idx] = nil;
															end
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_41ABD = 8;
														end
														if (FlatIdent_41ABD == 4) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_41ABD = 5;
														end
														if (5 == FlatIdent_41ABD) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_41ABD = 6;
														end
														if (6 == FlatIdent_41ABD) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															FlatIdent_41ABD = 7;
														end
														if (3 == FlatIdent_41ABD) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_41ABD = 4;
														end
														if (9 == FlatIdent_41ABD) then
															A = Inst[2];
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															break;
														end
														if (FlatIdent_41ABD == 1) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															FlatIdent_41ABD = 2;
														end
													end
												else
													local B;
													local A;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													B = Stk[Inst[4]];
													if not B then
														VIP = VIP + 1;
													else
														local FlatIdent_7C89 = 0;
														while true do
															if (FlatIdent_7C89 == 0) then
																Stk[Inst[2]] = B;
																VIP = Inst[3];
																break;
															end
														end
													end
												end
											elseif (Enum > 38) then
												local FlatIdent_D895 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_D895 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_D895 = 4;
													end
													if (FlatIdent_D895 == 2) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_D895 = 3;
													end
													if (FlatIdent_D895 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_D895 = 1;
													end
													if (4 == FlatIdent_D895) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_D895 == 1) then
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_D895 = 2;
													end
												end
											else
												local FlatIdent_3BBAF = 0;
												local A;
												while true do
													if (FlatIdent_3BBAF == 0) then
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3BBAF = 1;
													end
													if (FlatIdent_3BBAF == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_3BBAF = 5;
													end
													if (FlatIdent_3BBAF == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3BBAF = 6;
													end
													if (FlatIdent_3BBAF == 1) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3BBAF = 2;
													end
													if (FlatIdent_3BBAF == 3) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_3BBAF = 4;
													end
													if (FlatIdent_3BBAF == 6) then
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_3BBAF == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3BBAF = 3;
													end
												end
											end
										elseif (Enum <= 41) then
											if (Enum == 40) then
												local FlatIdent_45D0C = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_45D0C == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_45D0C = 4;
													end
													if (FlatIdent_45D0C == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if (Inst[2] < Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_45D0C == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D0C = 6;
													end
													if (FlatIdent_45D0C == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D0C = 8;
													end
													if (FlatIdent_45D0C == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_45D0C = 5;
													end
													if (FlatIdent_45D0C == 1) then
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_45D0C = 2;
													end
													if (FlatIdent_45D0C == 6) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_45D0C = 7;
													end
													if (FlatIdent_45D0C == 0) then
														B = nil;
														A = nil;
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D0C = 1;
													end
													if (FlatIdent_45D0C == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45D0C = 3;
													end
													if (FlatIdent_45D0C == 8) then
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_45D0C = 9;
													end
												end
											else
												do
													return Stk[Inst[2]];
												end
											end
										elseif (Enum <= 42) then
											if (Stk[Inst[2]] == Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum > 43) then
											local FlatIdent_73069 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_73069 == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_73069 = 6;
												end
												if (FlatIdent_73069 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_73069 = 2;
												end
												if (11 == FlatIdent_73069) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													B = Stk[Inst[4]];
													if not B then
														VIP = VIP + 1;
													else
														local FlatIdent_6F0B1 = 0;
														while true do
															if (0 == FlatIdent_6F0B1) then
																Stk[Inst[2]] = B;
																VIP = Inst[3];
																break;
															end
														end
													end
													break;
												end
												if (4 == FlatIdent_73069) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_73069 = 5;
												end
												if (FlatIdent_73069 == 3) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_73069 = 4;
												end
												if (FlatIdent_73069 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_73069 = 7;
												end
												if (FlatIdent_73069 == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_73069 = 11;
												end
												if (7 == FlatIdent_73069) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_73069 = 8;
												end
												if (8 == FlatIdent_73069) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_73069 = 9;
												end
												if (FlatIdent_73069 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_73069 = 1;
												end
												if (FlatIdent_73069 == 9) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_73069 = 10;
												end
												if (FlatIdent_73069 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_73069 = 3;
												end
											end
										else
											local A = Inst[2];
											local C = Inst[4];
											local CB = A + 2;
											local Result = {Stk[A](Stk[A + 1], Stk[CB])};
											for Idx = 1, C do
												Stk[CB + Idx] = Result[Idx];
											end
											local R = Result[1];
											if R then
												local FlatIdent_66193 = 0;
												while true do
													if (FlatIdent_66193 == 0) then
														Stk[CB] = R;
														VIP = Inst[3];
														break;
													end
												end
											else
												VIP = VIP + 1;
											end
										end
									elseif (Enum <= 48) then
										if (Enum <= 46) then
											if (Enum == 45) then
												local FlatIdent_89940 = 0;
												local A;
												while true do
													if (FlatIdent_89940 == 5) then
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_89940 == 4) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_89940 = 5;
													end
													if (1 == FlatIdent_89940) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_89940 = 2;
													end
													if (FlatIdent_89940 == 0) then
														A = nil;
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_89940 = 1;
													end
													if (FlatIdent_89940 == 3) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_89940 = 4;
													end
													if (FlatIdent_89940 == 2) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_89940 = 3;
													end
												end
											else
												local FlatIdent_8ECD7 = 0;
												while true do
													if (FlatIdent_8ECD7 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_8ECD7 = 2;
													end
													if (FlatIdent_8ECD7 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8ECD7 = 3;
													end
													if (FlatIdent_8ECD7 == 0) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_8ECD7 = 1;
													end
													if (FlatIdent_8ECD7 == 3) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														break;
													end
												end
											end
										elseif (Enum > 47) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
										else
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										end
									elseif (Enum <= 50) then
										if (Enum > 49) then
											Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
										else
											local FlatIdent_522F1 = 0;
											while true do
												if (FlatIdent_522F1 == 4) then
													if (Stk[Inst[2]] == Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_522F1 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_522F1 = 3;
												end
												if (FlatIdent_522F1 == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_522F1 = 1;
												end
												if (FlatIdent_522F1 == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_522F1 = 4;
												end
												if (FlatIdent_522F1 == 1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_522F1 = 2;
												end
											end
										end
									elseif (Enum <= 51) then
										local FlatIdent_277A4 = 0;
										local Edx;
										local Results;
										local B;
										local A;
										while true do
											if (0 == FlatIdent_277A4) then
												Edx = nil;
												Results = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_277A4 = 1;
											end
											if (FlatIdent_277A4 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = not Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_277A4 = 2;
											end
											if (FlatIdent_277A4 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_277A4 = 5;
											end
											if (FlatIdent_277A4 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_277A4 = 3;
											end
											if (FlatIdent_277A4 == 6) then
												Results = {Stk[A](Stk[A + 1])};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_3423 = 0;
													while true do
														if (0 == FlatIdent_3423) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_277A4 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_277A4 = 6;
											end
											if (FlatIdent_277A4 == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_277A4 = 4;
											end
										end
									elseif (Enum == 52) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									else
										local FlatIdent_6B578 = 0;
										local A;
										while true do
											if (FlatIdent_6B578 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6B578 = 1;
											end
											if (FlatIdent_6B578 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B578 = 5;
											end
											if (3 == FlatIdent_6B578) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
												FlatIdent_6B578 = 4;
											end
											if (2 == FlatIdent_6B578) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_6B578 = 3;
											end
											if (5 == FlatIdent_6B578) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6B578 = 6;
											end
											if (FlatIdent_6B578 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_6B578 = 2;
											end
											if (FlatIdent_6B578 == 6) then
												VIP = Inst[3];
												break;
											end
										end
									end
								elseif (Enum <= 62) then
									if (Enum <= 57) then
										if (Enum <= 55) then
											if (Enum == 54) then
												local FlatIdent_2CA66 = 0;
												while true do
													if (4 == FlatIdent_2CA66) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														FlatIdent_2CA66 = 5;
													end
													if (FlatIdent_2CA66 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_2CA66 = 4;
													end
													if (FlatIdent_2CA66 == 9) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_2CA66 = 10;
													end
													if (FlatIdent_2CA66 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2CA66 = 9;
													end
													if (FlatIdent_2CA66 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2CA66 = 6;
													end
													if (FlatIdent_2CA66 == 0) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_2CA66 = 1;
													end
													if (FlatIdent_2CA66 == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														do
															return;
														end
														break;
													end
													if (FlatIdent_2CA66 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2CA66 = 3;
													end
													if (FlatIdent_2CA66 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_2CA66 = 11;
													end
													if (FlatIdent_2CA66 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														FlatIdent_2CA66 = 8;
													end
													if (FlatIdent_2CA66 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														FlatIdent_2CA66 = 2;
													end
													if (FlatIdent_2CA66 == 6) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_2CA66 = 7;
													end
												end
											else
												local FlatIdent_72D23 = 0;
												local A;
												while true do
													if (FlatIdent_72D23 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_72D23 = 5;
													end
													if (FlatIdent_72D23 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_72D23 = 4;
													end
													if (FlatIdent_72D23 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_72D23 = 7;
													end
													if (FlatIdent_72D23 == 1) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_72D23 = 2;
													end
													if (FlatIdent_72D23 == 5) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_72D23 = 6;
													end
													if (FlatIdent_72D23 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_72D23 == 2) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_72D23 = 3;
													end
													if (FlatIdent_72D23 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_72D23 = 1;
													end
												end
											end
										elseif (Enum > 56) then
											local FlatIdent_86FCC = 0;
											while true do
												if (FlatIdent_86FCC == 0) then
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													break;
												end
											end
										else
											local FlatIdent_10177 = 0;
											while true do
												if (FlatIdent_10177 == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 6;
												end
												if (FlatIdent_10177 == 6) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
												if (FlatIdent_10177 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 5;
												end
												if (FlatIdent_10177 == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 4;
												end
												if (FlatIdent_10177 == 2) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 3;
												end
												if (0 == FlatIdent_10177) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 1;
												end
												if (1 == FlatIdent_10177) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10177 = 2;
												end
											end
										end
									elseif (Enum <= 59) then
										if (Enum > 58) then
											local FlatIdent_5CDFA = 0;
											local A;
											while true do
												if (4 == FlatIdent_5CDFA) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5CDFA = 5;
												end
												if (FlatIdent_5CDFA == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													FlatIdent_5CDFA = 1;
												end
												if (1 == FlatIdent_5CDFA) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5CDFA = 2;
												end
												if (FlatIdent_5CDFA == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_5CDFA = 6;
												end
												if (FlatIdent_5CDFA == 6) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5CDFA = 7;
												end
												if (FlatIdent_5CDFA == 2) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_5CDFA = 3;
												end
												if (7 == FlatIdent_5CDFA) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_5CDFA == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5CDFA = 4;
												end
											end
										else
											local FlatIdent_4B329 = 0;
											local A;
											while true do
												if (FlatIdent_4B329 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4B329 = 1;
												end
												if (FlatIdent_4B329 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_4B329 = 3;
												end
												if (FlatIdent_4B329 == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_4B329 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_4B329 = 7;
												end
												if (FlatIdent_4B329 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_4B329 = 6;
												end
												if (FlatIdent_4B329 == 7) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_4B329 = 8;
												end
												if (3 == FlatIdent_4B329) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_4B329 = 4;
												end
												if (FlatIdent_4B329 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4B329 = 5;
												end
												if (FlatIdent_4B329 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4B329 = 9;
												end
												if (FlatIdent_4B329 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_4B329 = 2;
												end
												if (9 == FlatIdent_4B329) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_4B329 = 10;
												end
											end
										end
									elseif (Enum <= 60) then
										local FlatIdent_39FCB = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_39FCB == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_39FCB = 3;
											end
											if (FlatIdent_39FCB == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_39FCB = 10;
											end
											if (FlatIdent_39FCB == 1) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_39FCB = 2;
											end
											if (FlatIdent_39FCB == 7) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_39FCB = 8;
											end
											if (FlatIdent_39FCB == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_39FCB = 4;
											end
											if (FlatIdent_39FCB == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_39FCB = 1;
											end
											if (FlatIdent_39FCB == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_39FCB = 7;
											end
											if (FlatIdent_39FCB == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_39FCB = 6;
											end
											if (FlatIdent_39FCB == 8) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_39FCB = 9;
											end
											if (FlatIdent_39FCB == 10) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_39FCB == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_39FCB = 5;
											end
										end
									elseif (Enum == 61) then
										local FlatIdent_12809 = 0;
										local A;
										while true do
											if (FlatIdent_12809 == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_12809 = 3;
											end
											if (FlatIdent_12809 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_12809 = 6;
											end
											if (FlatIdent_12809 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_12809 = 7;
											end
											if (0 == FlatIdent_12809) then
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_12809 = 1;
											end
											if (FlatIdent_12809 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_12809 = 4;
											end
											if (FlatIdent_12809 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_12809 = 2;
											end
											if (FlatIdent_12809 == 7) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_12809 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_12809 = 5;
											end
										end
									else
										local FlatIdent_91215 = 0;
										local A;
										while true do
											if (FlatIdent_91215 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 14;
											end
											if (24 == FlatIdent_91215) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 25;
											end
											if (FlatIdent_91215 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_91215 = 4;
											end
											if (FlatIdent_91215 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_91215 = 3;
											end
											if (FlatIdent_91215 == 14) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_91215 = 15;
											end
											if (FlatIdent_91215 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_91215 = 1;
											end
											if (FlatIdent_91215 == 23) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 24;
											end
											if (FlatIdent_91215 == 5) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 6;
											end
											if (FlatIdent_91215 == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_91215 = 9;
											end
											if (FlatIdent_91215 == 26) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 27;
											end
											if (FlatIdent_91215 == 20) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_91215 = 21;
											end
											if (19 == FlatIdent_91215) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_91215 = 20;
											end
											if (FlatIdent_91215 == 17) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_91215 = 18;
											end
											if (FlatIdent_91215 == 25) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 26;
											end
											if (FlatIdent_91215 == 27) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (FlatIdent_91215 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_91215 = 2;
											end
											if (FlatIdent_91215 == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 12;
											end
											if (10 == FlatIdent_91215) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 11;
											end
											if (FlatIdent_91215 == 4) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 5;
											end
											if (FlatIdent_91215 == 7) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 8;
											end
											if (FlatIdent_91215 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_91215 = 13;
											end
											if (FlatIdent_91215 == 21) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_91215 = 22;
											end
											if (FlatIdent_91215 == 18) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_91215 = 19;
											end
											if (FlatIdent_91215 == 6) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91215 = 7;
											end
											if (FlatIdent_91215 == 16) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 17;
											end
											if (FlatIdent_91215 == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_91215 = 10;
											end
											if (FlatIdent_91215 == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_91215 = 23;
											end
											if (FlatIdent_91215 == 15) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_91215 = 16;
											end
										end
									end
								elseif (Enum <= 66) then
									if (Enum <= 64) then
										if (Enum > 63) then
											local FlatIdent_6E3CB = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_6E3CB == 25) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 26;
												end
												if (20 == FlatIdent_6E3CB) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 21;
												end
												if (FlatIdent_6E3CB == 29) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_6E3CB = 30;
												end
												if (FlatIdent_6E3CB == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_6E3CB = 8;
												end
												if (FlatIdent_6E3CB == 15) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 16;
												end
												if (FlatIdent_6E3CB == 23) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_6E3CB = 24;
												end
												if (28 == FlatIdent_6E3CB) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 29;
												end
												if (FlatIdent_6E3CB == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 6;
												end
												if (FlatIdent_6E3CB == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_6E3CB = 5;
												end
												if (FlatIdent_6E3CB == 18) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_6E3CB = 19;
												end
												if (FlatIdent_6E3CB == 22) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 23;
												end
												if (FlatIdent_6E3CB == 12) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 13;
												end
												if (FlatIdent_6E3CB == 6) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_6E3CB = 7;
												end
												if (2 == FlatIdent_6E3CB) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6E3CB = 3;
												end
												if (FlatIdent_6E3CB == 16) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6E3CB = 17;
												end
												if (9 == FlatIdent_6E3CB) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_6E3CB = 10;
												end
												if (FlatIdent_6E3CB == 19) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 20;
												end
												if (14 == FlatIdent_6E3CB) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_6E3CB = 15;
												end
												if (FlatIdent_6E3CB == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 4;
												end
												if (FlatIdent_6E3CB == 26) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 27;
												end
												if (FlatIdent_6E3CB == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_6E3CB = 18;
												end
												if (11 == FlatIdent_6E3CB) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_6E3CB = 12;
												end
												if (FlatIdent_6E3CB == 21) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 22;
												end
												if (FlatIdent_6E3CB == 24) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 25;
												end
												if (FlatIdent_6E3CB == 27) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 28;
												end
												if (FlatIdent_6E3CB == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 1;
												end
												if (FlatIdent_6E3CB == 30) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													break;
												end
												if (FlatIdent_6E3CB == 1) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 2;
												end
												if (FlatIdent_6E3CB == 13) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6E3CB = 14;
												end
												if (FlatIdent_6E3CB == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 11;
												end
												if (FlatIdent_6E3CB == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6E3CB = 9;
												end
											end
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										end
									elseif (Enum == 65) then
										local FlatIdent_D7F6 = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_D7F6 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_D7F6 = 3;
											end
											if (FlatIdent_D7F6 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_D7F6 = 6;
											end
											if (FlatIdent_D7F6 == 1) then
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D7F6 = 2;
											end
											if (FlatIdent_D7F6 == 6) then
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_D7F6 == 4) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_D7F6 = 5;
											end
											if (3 == FlatIdent_D7F6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_D7F6 = 4;
											end
											if (FlatIdent_D7F6 == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_D7F6 = 1;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum <= 68) then
									if (Enum == 67) then
										local FlatIdent_96219 = 0;
										local B;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_96219 == 6) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_96219 = 7;
											end
											if (FlatIdent_96219 == 2) then
												for Idx = A, Top do
													local FlatIdent_48EC5 = 0;
													while true do
														if (FlatIdent_48EC5 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_96219 = 3;
											end
											if (5 == FlatIdent_96219) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 6;
											end
											if (FlatIdent_96219 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_96219 = 5;
											end
											if (FlatIdent_96219 == 1) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_96219 = 2;
											end
											if (FlatIdent_96219 == 3) then
												Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_96219 = 4;
											end
											if (FlatIdent_96219 == 0) then
												B = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_96219 = 1;
											end
											if (FlatIdent_96219 == 7) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
										end
									else
										local FlatIdent_4BBF = 0;
										local B;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_4BBF == 0) then
												B = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_4BBF = 1;
											end
											if (FlatIdent_4BBF == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4BBF = 6;
											end
											if (4 == FlatIdent_4BBF) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_4BBF = 5;
											end
											if (FlatIdent_4BBF == 1) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_4BBF = 2;
											end
											if (FlatIdent_4BBF == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4BBF = 3;
											end
											if (3 == FlatIdent_4BBF) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4BBF = 4;
											end
											if (FlatIdent_4BBF == 6) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
										end
									end
								elseif (Enum <= 69) then
									local FlatIdent_98327 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_98327 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_98327 = 1;
										end
										if (FlatIdent_98327 == 6) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_98327 = 7;
										end
										if (FlatIdent_98327 == 14) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_98327 == 10) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_98327 = 11;
										end
										if (FlatIdent_98327 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_98327 = 12;
										end
										if (FlatIdent_98327 == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_98327 = 5;
										end
										if (12 == FlatIdent_98327) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											FlatIdent_98327 = 13;
										end
										if (FlatIdent_98327 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_98327 = 4;
										end
										if (FlatIdent_98327 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_98327 = 2;
										end
										if (FlatIdent_98327 == 13) then
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_98327 = 14;
										end
										if (2 == FlatIdent_98327) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_98327 = 3;
										end
										if (FlatIdent_98327 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_98327 = 10;
										end
										if (FlatIdent_98327 == 7) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_98327 = 8;
										end
										if (FlatIdent_98327 == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_98327 = 9;
										end
										if (FlatIdent_98327 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_98327 = 6;
										end
									end
								elseif (Enum > 70) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_45FBD = 0;
									local B;
									local A;
									while true do
										if (15 == FlatIdent_45FBD) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 16;
										end
										if (FlatIdent_45FBD == 22) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 23;
										end
										if (FlatIdent_45FBD == 18) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 19;
										end
										if (FlatIdent_45FBD == 20) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_45FBD = 21;
										end
										if (FlatIdent_45FBD == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 10;
										end
										if (FlatIdent_45FBD == 11) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_45FBD = 12;
										end
										if (FlatIdent_45FBD == 1) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_45FBD = 2;
										end
										if (FlatIdent_45FBD == 19) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_45FBD = 20;
										end
										if (6 == FlatIdent_45FBD) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_45FBD = 7;
										end
										if (FlatIdent_45FBD == 10) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_45FBD = 11;
										end
										if (FlatIdent_45FBD == 4) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_45FBD = 5;
										end
										if (21 == FlatIdent_45FBD) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_45FBD = 22;
										end
										if (FlatIdent_45FBD == 23) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_45FBD = 24;
										end
										if (13 == FlatIdent_45FBD) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_45FBD = 14;
										end
										if (5 == FlatIdent_45FBD) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 6;
										end
										if (FlatIdent_45FBD == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 4;
										end
										if (FlatIdent_45FBD == 24) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
										if (FlatIdent_45FBD == 16) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_45FBD = 17;
										end
										if (FlatIdent_45FBD == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_45FBD = 1;
										end
										if (FlatIdent_45FBD == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_45FBD = 9;
										end
										if (FlatIdent_45FBD == 12) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_45FBD = 13;
										end
										if (FlatIdent_45FBD == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_45FBD = 3;
										end
										if (FlatIdent_45FBD == 7) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_45FBD = 8;
										end
										if (FlatIdent_45FBD == 17) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_45FBD = 18;
										end
										if (FlatIdent_45FBD == 14) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_45FBD = 15;
										end
									end
								end
							elseif (Enum <= 107) then
								if (Enum <= 89) then
									if (Enum <= 80) then
										if (Enum <= 75) then
											if (Enum <= 73) then
												if (Enum > 72) then
													local Edx;
													local Results, Limit;
													local A;
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_DFD4 = 0;
														while true do
															if (0 == FlatIdent_DFD4) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_9195A = 0;
														while true do
															if (0 == FlatIdent_9195A) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_50F9C = 0;
														while true do
															if (FlatIdent_50F9C == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
												else
													local FlatIdent_55E6D = 0;
													local A;
													while true do
														if (FlatIdent_55E6D == 14) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 15;
														end
														if (25 == FlatIdent_55E6D) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_55E6D = 26;
														end
														if (FlatIdent_55E6D == 6) then
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 7;
														end
														if (FlatIdent_55E6D == 22) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															FlatIdent_55E6D = 23;
														end
														if (FlatIdent_55E6D == 7) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_55E6D = 8;
														end
														if (13 == FlatIdent_55E6D) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 14;
														end
														if (FlatIdent_55E6D == 21) then
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 22;
														end
														if (FlatIdent_55E6D == 5) then
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 6;
														end
														if (FlatIdent_55E6D == 19) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_55E6D = 20;
														end
														if (FlatIdent_55E6D == 20) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 21;
														end
														if (FlatIdent_55E6D == 23) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_55E6D = 24;
														end
														if (24 == FlatIdent_55E6D) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															FlatIdent_55E6D = 25;
														end
														if (FlatIdent_55E6D == 1) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															FlatIdent_55E6D = 2;
														end
														if (FlatIdent_55E6D == 26) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_55E6D = 27;
														end
														if (12 == FlatIdent_55E6D) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 13;
														end
														if (FlatIdent_55E6D == 18) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															FlatIdent_55E6D = 19;
														end
														if (FlatIdent_55E6D == 15) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 16;
														end
														if (FlatIdent_55E6D == 8) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_55E6D = 9;
														end
														if (FlatIdent_55E6D == 17) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_55E6D = 18;
														end
														if (FlatIdent_55E6D == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_55E6D = 3;
														end
														if (FlatIdent_55E6D == 16) then
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_55E6D = 17;
														end
														if (FlatIdent_55E6D == 9) then
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															FlatIdent_55E6D = 10;
														end
														if (FlatIdent_55E6D == 11) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_55E6D = 12;
														end
														if (FlatIdent_55E6D == 27) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															break;
														end
														if (FlatIdent_55E6D == 4) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_55E6D = 5;
														end
														if (FlatIdent_55E6D == 3) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_55E6D = 4;
														end
														if (FlatIdent_55E6D == 10) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_55E6D = 11;
														end
														if (FlatIdent_55E6D == 0) then
															A = nil;
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_55E6D = 1;
														end
													end
												end
											elseif (Enum > 74) then
												local FlatIdent_4488E = 0;
												while true do
													if (FlatIdent_4488E == 2) then
														Upvalues[Inst[3]] = Stk[Inst[2]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4488E = 3;
													end
													if (5 == FlatIdent_4488E) then
														Upvalues[Inst[3]] = Stk[Inst[2]];
														break;
													end
													if (FlatIdent_4488E == 4) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4488E = 5;
													end
													if (FlatIdent_4488E == 0) then
														Upvalues[Inst[3]] = Stk[Inst[2]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4488E = 1;
													end
													if (3 == FlatIdent_4488E) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4488E = 4;
													end
													if (1 == FlatIdent_4488E) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4488E = 2;
													end
												end
											else
												local FlatIdent_2B3ED = 0;
												local A;
												while true do
													if (FlatIdent_2B3ED == 0) then
														A = nil;
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_2B3ED = 1;
													end
													if (FlatIdent_2B3ED == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_2B3ED = 7;
													end
													if (FlatIdent_2B3ED == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_2B3ED = 4;
													end
													if (FlatIdent_2B3ED == 5) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_2B3ED = 6;
													end
													if (FlatIdent_2B3ED == 2) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_2B3ED = 3;
													end
													if (FlatIdent_2B3ED == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2B3ED = 2;
													end
													if (FlatIdent_2B3ED == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2B3ED = 5;
													end
													if (7 == FlatIdent_2B3ED) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
												end
											end
										elseif (Enum <= 77) then
											if (Enum > 76) then
												local FlatIdent_6EF16 = 0;
												local A;
												while true do
													if (FlatIdent_6EF16 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 7;
													end
													if (FlatIdent_6EF16 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 5;
													end
													if (FlatIdent_6EF16 == 8) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_6EF16 = 9;
													end
													if (FlatIdent_6EF16 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 2;
													end
													if (FlatIdent_6EF16 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 3;
													end
													if (FlatIdent_6EF16 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 6;
													end
													if (FlatIdent_6EF16 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 8;
													end
													if (FlatIdent_6EF16 == 9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														break;
													end
													if (FlatIdent_6EF16 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 1;
													end
													if (FlatIdent_6EF16 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														FlatIdent_6EF16 = 4;
													end
												end
											else
												local FlatIdent_94CF4 = 0;
												local A;
												while true do
													if (FlatIdent_94CF4 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_94CF4 = 1;
													end
													if (1 == FlatIdent_94CF4) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_94CF4 = 2;
													end
													if (FlatIdent_94CF4 == 5) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_94CF4 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														FlatIdent_94CF4 = 4;
													end
													if (FlatIdent_94CF4 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_94CF4 = 5;
													end
													if (FlatIdent_94CF4 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_94CF4 = 3;
													end
												end
											end
										elseif (Enum <= 78) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum == 79) then
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
										else
											local B;
											local T;
											local A;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										end
									elseif (Enum <= 84) then
										if (Enum <= 82) then
											if (Enum == 81) then
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											else
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											end
										elseif (Enum == 83) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											local FlatIdent_5DE9C = 0;
											local A;
											while true do
												if (4 == FlatIdent_5DE9C) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_5DE9C = 5;
												end
												if (FlatIdent_5DE9C == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_5DE9C = 2;
												end
												if (FlatIdent_5DE9C == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5DE9C = 1;
												end
												if (FlatIdent_5DE9C == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5DE9C = 7;
												end
												if (FlatIdent_5DE9C == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_5DE9C = 6;
												end
												if (8 == FlatIdent_5DE9C) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5DE9C = 9;
												end
												if (FlatIdent_5DE9C == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_5DE9C = 3;
												end
												if (FlatIdent_5DE9C == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_5DE9C = 8;
												end
												if (FlatIdent_5DE9C == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5DE9C = 4;
												end
												if (FlatIdent_5DE9C == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										end
									elseif (Enum <= 86) then
										if (Enum > 85) then
											local FlatIdent_8B90B = 0;
											while true do
												if (4 == FlatIdent_8B90B) then
													if (Stk[Inst[2]] == Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (3 == FlatIdent_8B90B) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8B90B = 4;
												end
												if (FlatIdent_8B90B == 1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8B90B = 2;
												end
												if (FlatIdent_8B90B == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8B90B = 3;
												end
												if (FlatIdent_8B90B == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8B90B = 1;
												end
											end
										else
											Stk[Inst[2]] = Upvalues[Inst[3]];
										end
									elseif (Enum <= 87) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									elseif (Enum == 88) then
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
									else
										local FlatIdent_6E54 = 0;
										local A;
										while true do
											if (FlatIdent_6E54 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_6E54 = 4;
											end
											if (FlatIdent_6E54 == 7) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_6E54 == 0) then
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_6E54 = 1;
											end
											if (FlatIdent_6E54 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_6E54 = 6;
											end
											if (FlatIdent_6E54 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_6E54 = 3;
											end
											if (FlatIdent_6E54 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_6E54 = 5;
											end
											if (FlatIdent_6E54 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_6E54 = 2;
											end
											if (FlatIdent_6E54 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6E54 = 7;
											end
										end
									end
								elseif (Enum <= 98) then
									if (Enum <= 93) then
										if (Enum <= 91) then
											if (Enum == 90) then
												local FlatIdent_1907D = 0;
												while true do
													if (FlatIdent_1907D == 0) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1907D = 1;
													end
													if (5 == FlatIdent_1907D) then
														do
															return;
														end
														break;
													end
													if (FlatIdent_1907D == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1907D = 4;
													end
													if (FlatIdent_1907D == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1907D = 2;
													end
													if (FlatIdent_1907D == 4) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1907D = 5;
													end
													if (FlatIdent_1907D == 2) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1907D = 3;
													end
												end
											else
												local A;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											end
										elseif (Enum == 92) then
											local FlatIdent_2D916 = 0;
											local A;
											while true do
												if (FlatIdent_2D916 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2D916 = 6;
												end
												if (FlatIdent_2D916 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_2D916 == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_2D916 = 2;
												end
												if (2 == FlatIdent_2D916) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_2D916 = 3;
												end
												if (0 == FlatIdent_2D916) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2D916 = 1;
												end
												if (FlatIdent_2D916 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2D916 = 5;
												end
												if (FlatIdent_2D916 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2D916 = 4;
												end
												if (6 == FlatIdent_2D916) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2D916 = 7;
												end
											end
										else
											local FlatIdent_21608 = 0;
											local A;
											while true do
												if (FlatIdent_21608 == 12) then
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_21608 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_21608 = 9;
												end
												if (FlatIdent_21608 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_21608 = 4;
												end
												if (FlatIdent_21608 == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_21608 = 7;
												end
												if (7 == FlatIdent_21608) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_21608 = 8;
												end
												if (4 == FlatIdent_21608) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_21608 = 5;
												end
												if (FlatIdent_21608 == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_21608 = 11;
												end
												if (FlatIdent_21608 == 5) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_21608 = 6;
												end
												if (FlatIdent_21608 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_21608 = 3;
												end
												if (FlatIdent_21608 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_21608 = 2;
												end
												if (FlatIdent_21608 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_21608 = 1;
												end
												if (FlatIdent_21608 == 9) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_21608 = 10;
												end
												if (FlatIdent_21608 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_21608 = 12;
												end
											end
										end
									elseif (Enum <= 95) then
										if (Enum > 94) then
											local FlatIdent_621D7 = 0;
											while true do
												if (2 == FlatIdent_621D7) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_621D7 = 3;
												end
												if (FlatIdent_621D7 == 0) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_621D7 = 1;
												end
												if (FlatIdent_621D7 == 3) then
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_621D7 = 4;
												end
												if (FlatIdent_621D7 == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_621D7 == 4) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_621D7 = 5;
												end
												if (1 == FlatIdent_621D7) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_621D7 = 2;
												end
											end
										else
											local FlatIdent_7CA52 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_7CA52 == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_7CA52 = 11;
												end
												if (2 == FlatIdent_7CA52) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_7CA52 = 3;
												end
												if (FlatIdent_7CA52 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_7CA52 = 1;
												end
												if (FlatIdent_7CA52 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_7CA52 = 4;
												end
												if (FlatIdent_7CA52 == 17) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_7CA52 = 18;
												end
												if (FlatIdent_7CA52 == 14) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7CA52 = 15;
												end
												if (FlatIdent_7CA52 == 6) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7CA52 = 7;
												end
												if (15 == FlatIdent_7CA52) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7CA52 = 16;
												end
												if (FlatIdent_7CA52 == 13) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7CA52 = 14;
												end
												if (FlatIdent_7CA52 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_7CA52 = 2;
												end
												if (FlatIdent_7CA52 == 5) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7CA52 = 6;
												end
												if (FlatIdent_7CA52 == 19) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_7CA52 = 20;
												end
												if (FlatIdent_7CA52 == 4) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_7CA52 = 5;
												end
												if (7 == FlatIdent_7CA52) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_7CA52 = 8;
												end
												if (FlatIdent_7CA52 == 8) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_7CA52 = 9;
												end
												if (18 == FlatIdent_7CA52) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_7CA52 = 19;
												end
												if (FlatIdent_7CA52 == 16) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_7CA52 = 17;
												end
												if (FlatIdent_7CA52 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_7CA52 = 12;
												end
												if (FlatIdent_7CA52 == 20) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_7CA52 == 9) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_7CA52 = 10;
												end
												if (12 == FlatIdent_7CA52) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_7CA52 = 13;
												end
											end
										end
									elseif (Enum <= 96) then
										local FlatIdent_84D38 = 0;
										local A;
										while true do
											if (FlatIdent_84D38 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_84D38 = 2;
											end
											if (FlatIdent_84D38 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_84D38 = 1;
											end
											if (FlatIdent_84D38 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_84D38 = 3;
											end
											if (FlatIdent_84D38 == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									elseif (Enum == 97) then
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local FlatIdent_1FF3C = 0;
										local A;
										while true do
											if (FlatIdent_1FF3C == 5) then
												do
													return;
												end
												break;
											end
											if (FlatIdent_1FF3C == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1FF3C = 2;
											end
											if (FlatIdent_1FF3C == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_1FF3C = 3;
											end
											if (FlatIdent_1FF3C == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1FF3C = 5;
											end
											if (FlatIdent_1FF3C == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1FF3C = 4;
											end
											if (0 == FlatIdent_1FF3C) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1FF3C = 1;
											end
										end
									end
								elseif (Enum <= 102) then
									if (Enum <= 100) then
										if (Enum > 99) then
											local FlatIdent_74006 = 0;
											local A;
											while true do
												if (FlatIdent_74006 == 1) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_74006 = 2;
												end
												if (FlatIdent_74006 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_74006 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_74006 = 4;
												end
												if (FlatIdent_74006 == 4) then
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_74006 = 5;
												end
												if (FlatIdent_74006 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_74006 = 3;
												end
												if (6 == FlatIdent_74006) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_74006 = 7;
												end
												if (FlatIdent_74006 == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_74006 = 6;
												end
												if (FlatIdent_74006 == 0) then
													A = nil;
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_74006 = 1;
												end
											end
										else
											local FlatIdent_2DE10 = 0;
											local A;
											while true do
												if (FlatIdent_2DE10 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_2DE10 = 5;
												end
												if (FlatIdent_2DE10 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_2DE10 = 3;
												end
												if (FlatIdent_2DE10 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2DE10 = 9;
												end
												if (6 == FlatIdent_2DE10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2DE10 = 7;
												end
												if (FlatIdent_2DE10 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2DE10 = 2;
												end
												if (FlatIdent_2DE10 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2DE10 = 4;
												end
												if (FlatIdent_2DE10 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_2DE10 == 0) then
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_2DE10 = 1;
												end
												if (FlatIdent_2DE10 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_2DE10 = 6;
												end
												if (FlatIdent_2DE10 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_2DE10 = 8;
												end
											end
										end
									elseif (Enum == 101) then
										local FlatIdent_597A6 = 0;
										local Edx;
										local Results;
										local A;
										while true do
											if (FlatIdent_597A6 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_597A6 = 7;
											end
											if (FlatIdent_597A6 == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_597A6 = 3;
											end
											if (11 == FlatIdent_597A6) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Stk[A + 1])};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_3E230 = 0;
													while true do
														if (FlatIdent_3E230 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_597A6 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_597A6 = 8;
											end
											if (FlatIdent_597A6 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_597A6 = 2;
											end
											if (FlatIdent_597A6 == 0) then
												Edx = nil;
												Results = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_597A6 = 1;
											end
											if (FlatIdent_597A6 == 9) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_597A6 = 10;
											end
											if (FlatIdent_597A6 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_597A6 = 4;
											end
											if (5 == FlatIdent_597A6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_597A6 = 6;
											end
											if (FlatIdent_597A6 == 10) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_597A6 = 11;
											end
											if (8 == FlatIdent_597A6) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_597A6 = 9;
											end
											if (FlatIdent_597A6 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_597A6 = 5;
											end
										end
									else
										local FlatIdent_5471B = 0;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_5471B == 6) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												FlatIdent_5471B = 7;
											end
											if (FlatIdent_5471B == 8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												break;
											end
											if (FlatIdent_5471B == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5471B = 3;
											end
											if (FlatIdent_5471B == 0) then
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_5471B = 1;
											end
											if (FlatIdent_5471B == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5471B = 4;
											end
											if (FlatIdent_5471B == 5) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_5B4EF = 0;
													while true do
														if (FlatIdent_5B4EF == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_5471B = 6;
											end
											if (FlatIdent_5471B == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_5471B = 5;
											end
											if (FlatIdent_5471B == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5471B = 8;
											end
											if (FlatIdent_5471B == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5471B = 2;
											end
										end
									end
								elseif (Enum <= 104) then
									if (Enum == 103) then
										local FlatIdent_8982C = 0;
										local A;
										while true do
											if (FlatIdent_8982C == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8982C = 4;
											end
											if (FlatIdent_8982C == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8982C = 5;
											end
											if (6 == FlatIdent_8982C) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												FlatIdent_8982C = 7;
											end
											if (FlatIdent_8982C == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8982C = 3;
											end
											if (FlatIdent_8982C == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_8982C = 1;
											end
											if (FlatIdent_8982C == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_8982C = 6;
											end
											if (FlatIdent_8982C == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_8982C == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												FlatIdent_8982C = 2;
											end
										end
									else
										local A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
									end
								elseif (Enum <= 105) then
									local FlatIdent_34BCB = 0;
									local A;
									while true do
										if (FlatIdent_34BCB == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_34BCB = 9;
										end
										if (FlatIdent_34BCB == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_34BCB = 11;
										end
										if (FlatIdent_34BCB == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											FlatIdent_34BCB = 8;
										end
										if (FlatIdent_34BCB == 11) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											break;
										end
										if (5 == FlatIdent_34BCB) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											FlatIdent_34BCB = 6;
										end
										if (FlatIdent_34BCB == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_34BCB = 3;
										end
										if (FlatIdent_34BCB == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_34BCB = 5;
										end
										if (FlatIdent_34BCB == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_34BCB = 1;
										end
										if (FlatIdent_34BCB == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_34BCB = 2;
										end
										if (FlatIdent_34BCB == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_34BCB = 10;
										end
										if (FlatIdent_34BCB == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											FlatIdent_34BCB = 7;
										end
										if (FlatIdent_34BCB == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_34BCB = 4;
										end
									end
								elseif (Enum > 106) then
									Stk[Inst[2]] = #Stk[Inst[3]];
								else
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
								end
							elseif (Enum <= 125) then
								if (Enum <= 116) then
									if (Enum <= 111) then
										if (Enum <= 109) then
											if (Enum == 108) then
												local FlatIdent_964BF = 0;
												local A;
												local T;
												local B;
												while true do
													if (1 == FlatIdent_964BF) then
														B = Inst[3];
														for Idx = 1, B do
															T[Idx] = Stk[A + Idx];
														end
														break;
													end
													if (FlatIdent_964BF == 0) then
														A = Inst[2];
														T = Stk[A];
														FlatIdent_964BF = 1;
													end
												end
											else
												local FlatIdent_133C3 = 0;
												local A;
												while true do
													if (FlatIdent_133C3 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_133C3 = 5;
													end
													if (10 == FlatIdent_133C3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_133C3 = 11;
													end
													if (5 == FlatIdent_133C3) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_133C3 = 6;
													end
													if (FlatIdent_133C3 == 21) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_133C3 = 22;
													end
													if (11 == FlatIdent_133C3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 12;
													end
													if (FlatIdent_133C3 == 16) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_133C3 = 17;
													end
													if (FlatIdent_133C3 == 13) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 14;
													end
													if (FlatIdent_133C3 == 31) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_133C3 == 1) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_133C3 = 2;
													end
													if (FlatIdent_133C3 == 0) then
														A = nil;
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 1;
													end
													if (FlatIdent_133C3 == 14) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_133C3 = 15;
													end
													if (FlatIdent_133C3 == 17) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_133C3 = 18;
													end
													if (FlatIdent_133C3 == 19) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 20;
													end
													if (FlatIdent_133C3 == 28) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_133C3 = 29;
													end
													if (FlatIdent_133C3 == 27) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_133C3 = 28;
													end
													if (FlatIdent_133C3 == 25) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_133C3 = 26;
													end
													if (FlatIdent_133C3 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_133C3 = 4;
													end
													if (FlatIdent_133C3 == 30) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 31;
													end
													if (FlatIdent_133C3 == 26) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 27;
													end
													if (FlatIdent_133C3 == 8) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_133C3 = 9;
													end
													if (FlatIdent_133C3 == 18) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_133C3 = 19;
													end
													if (FlatIdent_133C3 == 24) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_133C3 = 25;
													end
													if (FlatIdent_133C3 == 23) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_133C3 = 24;
													end
													if (FlatIdent_133C3 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_133C3 = 3;
													end
													if (FlatIdent_133C3 == 20) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_133C3 = 21;
													end
													if (29 == FlatIdent_133C3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_133C3 = 30;
													end
													if (FlatIdent_133C3 == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 8;
													end
													if (FlatIdent_133C3 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_133C3 = 7;
													end
													if (FlatIdent_133C3 == 9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_133C3 = 10;
													end
													if (FlatIdent_133C3 == 12) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_133C3 = 13;
													end
													if (FlatIdent_133C3 == 15) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_133C3 = 16;
													end
													if (FlatIdent_133C3 == 22) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_133C3 = 23;
													end
												end
											end
										elseif (Enum > 110) then
											Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										else
											local FlatIdent_196AB = 0;
											while true do
												if (FlatIdent_196AB == 3) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_196AB = 4;
												end
												if (1 == FlatIdent_196AB) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_196AB = 2;
												end
												if (FlatIdent_196AB == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_196AB = 6;
												end
												if (FlatIdent_196AB == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_196AB = 3;
												end
												if (FlatIdent_196AB == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_196AB = 1;
												end
												if (FlatIdent_196AB == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_196AB = 5;
												end
												if (FlatIdent_196AB == 6) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
											end
										end
									elseif (Enum <= 113) then
										if (Enum == 112) then
											local FlatIdent_13030 = 0;
											local A;
											local Results;
											local Edx;
											while true do
												if (FlatIdent_13030 == 0) then
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
													FlatIdent_13030 = 1;
												end
												if (FlatIdent_13030 == 1) then
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_252D3 = 0;
														while true do
															if (0 == FlatIdent_252D3) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													break;
												end
											end
										else
											local A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									elseif (Enum <= 114) then
										local FlatIdent_5969 = 0;
										local A;
										while true do
											if (FlatIdent_5969 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5969 = 5;
											end
											if (FlatIdent_5969 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5969 = 7;
											end
											if (FlatIdent_5969 == 9) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_5969 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5969 = 4;
											end
											if (FlatIdent_5969 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5969 = 8;
											end
											if (FlatIdent_5969 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												FlatIdent_5969 = 2;
											end
											if (FlatIdent_5969 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5969 = 6;
											end
											if (FlatIdent_5969 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5969 = 9;
											end
											if (FlatIdent_5969 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_5969 = 3;
											end
											if (FlatIdent_5969 == 0) then
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_5969 = 1;
											end
										end
									elseif (Enum == 115) then
										local FlatIdent_1EAD4 = 0;
										local A;
										while true do
											if (FlatIdent_1EAD4 == 0) then
												A = Inst[2];
												Stk[A] = Stk[A]();
												break;
											end
										end
									else
										local FlatIdent_248DD = 0;
										local A;
										while true do
											if (FlatIdent_248DD == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_248DD = 10;
											end
											if (3 == FlatIdent_248DD) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_248DD = 4;
											end
											if (FlatIdent_248DD == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_248DD = 6;
											end
											if (FlatIdent_248DD == 7) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_248DD = 8;
											end
											if (FlatIdent_248DD == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_248DD = 9;
											end
											if (FlatIdent_248DD == 10) then
												Inst = Instr[VIP];
												if (Inst[2] < Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (0 == FlatIdent_248DD) then
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_248DD = 1;
											end
											if (FlatIdent_248DD == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
												FlatIdent_248DD = 5;
											end
											if (FlatIdent_248DD == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_248DD = 3;
											end
											if (FlatIdent_248DD == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_248DD = 7;
											end
											if (FlatIdent_248DD == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_248DD = 2;
											end
										end
									end
								elseif (Enum <= 120) then
									if (Enum <= 118) then
										if (Enum == 117) then
											local FlatIdent_6D772 = 0;
											local A;
											while true do
												if (FlatIdent_6D772 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6D772 = 1;
												end
												if (FlatIdent_6D772 == 2) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6D772 = 3;
												end
												if (FlatIdent_6D772 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													break;
												end
												if (FlatIdent_6D772 == 1) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6D772 = 2;
												end
												if (FlatIdent_6D772 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6D772 = 4;
												end
											end
										else
											local FlatIdent_10737 = 0;
											local A;
											while true do
												if (FlatIdent_10737 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_10737 = 4;
												end
												if (0 == FlatIdent_10737) then
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_10737 = 1;
												end
												if (FlatIdent_10737 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_10737 == 2) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_10737 = 3;
												end
												if (FlatIdent_10737 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10737 = 6;
												end
												if (FlatIdent_10737 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10737 = 2;
												end
												if (6 == FlatIdent_10737) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_10737 = 7;
												end
												if (FlatIdent_10737 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_10737 = 5;
												end
											end
										end
									elseif (Enum > 119) then
										Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
									else
										local FlatIdent_75496 = 0;
										while true do
											if (2 == FlatIdent_75496) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75496 = 3;
											end
											if (FlatIdent_75496 == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_75496 = 1;
											end
											if (FlatIdent_75496 == 3) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_75496 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_75496 = 2;
											end
										end
									end
								elseif (Enum <= 122) then
									if (Enum == 121) then
										local FlatIdent_536EB = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_536EB == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_536EB = 4;
											end
											if (FlatIdent_536EB == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_536EB = 3;
											end
											if (FlatIdent_536EB == 6) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_536EB == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_536EB = 6;
											end
											if (FlatIdent_536EB == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_536EB = 2;
											end
											if (FlatIdent_536EB == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = {};
												FlatIdent_536EB = 1;
											end
											if (FlatIdent_536EB == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_536EB = 5;
											end
										end
									else
										local FlatIdent_90D19 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_90D19 == 6) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_90D19 == 5) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90D19 = 6;
											end
											if (2 == FlatIdent_90D19) then
												for Idx = Inst[2], Inst[3] do
													Stk[Idx] = nil;
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_90D19 = 3;
											end
											if (FlatIdent_90D19 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90D19 = 2;
											end
											if (FlatIdent_90D19 == 3) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_90D19 = 4;
											end
											if (FlatIdent_90D19 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90D19 = 5;
											end
											if (FlatIdent_90D19 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_90D19 = 1;
											end
										end
									end
								elseif (Enum <= 123) then
									local FlatIdent_3BCF7 = 0;
									local A;
									while true do
										if (FlatIdent_3BCF7 == 0) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3BCF7 = 1;
										end
										if (FlatIdent_3BCF7 == 1) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_3BCF7 = 2;
										end
										if (FlatIdent_3BCF7 == 5) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_3BCF7 = 6;
										end
										if (3 == FlatIdent_3BCF7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_3BCF7 = 4;
										end
										if (FlatIdent_3BCF7 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3BCF7 = 5;
										end
										if (6 == FlatIdent_3BCF7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_3BCF7 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_3BCF7 = 3;
										end
									end
								elseif (Enum > 124) then
									local FlatIdent_6AFD8 = 0;
									local A;
									while true do
										if (FlatIdent_6AFD8 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 8;
										end
										if (FlatIdent_6AFD8 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_6AFD8 = 2;
										end
										if (FlatIdent_6AFD8 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 4;
										end
										if (20 == FlatIdent_6AFD8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 21;
										end
										if (23 == FlatIdent_6AFD8) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 24;
										end
										if (FlatIdent_6AFD8 == 25) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 26;
										end
										if (FlatIdent_6AFD8 == 15) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 16;
										end
										if (FlatIdent_6AFD8 == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 1;
										end
										if (FlatIdent_6AFD8 == 13) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 14;
										end
										if (5 == FlatIdent_6AFD8) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 6;
										end
										if (FlatIdent_6AFD8 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_6AFD8 = 3;
										end
										if (FlatIdent_6AFD8 == 19) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_6AFD8 = 20;
										end
										if (22 == FlatIdent_6AFD8) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 23;
										end
										if (9 == FlatIdent_6AFD8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 10;
										end
										if (FlatIdent_6AFD8 == 6) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 7;
										end
										if (FlatIdent_6AFD8 == 12) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_6AFD8 = 13;
										end
										if (FlatIdent_6AFD8 == 10) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_6AFD8 = 11;
										end
										if (FlatIdent_6AFD8 == 27) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (24 == FlatIdent_6AFD8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 25;
										end
										if (21 == FlatIdent_6AFD8) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 22;
										end
										if (18 == FlatIdent_6AFD8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_6AFD8 = 19;
										end
										if (FlatIdent_6AFD8 == 17) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 18;
										end
										if (FlatIdent_6AFD8 == 26) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 27;
										end
										if (FlatIdent_6AFD8 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_6AFD8 = 12;
										end
										if (FlatIdent_6AFD8 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 9;
										end
										if (FlatIdent_6AFD8 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6AFD8 = 17;
										end
										if (FlatIdent_6AFD8 == 14) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 15;
										end
										if (FlatIdent_6AFD8 == 4) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6AFD8 = 5;
										end
									end
								else
									local FlatIdent_75DF5 = 0;
									local A;
									while true do
										if (FlatIdent_75DF5 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_75DF5 = 3;
										end
										if (FlatIdent_75DF5 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_75DF5 = 1;
										end
										if (FlatIdent_75DF5 == 5) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (1 == FlatIdent_75DF5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_75DF5 = 2;
										end
										if (3 == FlatIdent_75DF5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_75DF5 = 4;
										end
										if (FlatIdent_75DF5 == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_75DF5 = 5;
										end
									end
								end
							elseif (Enum <= 134) then
								if (Enum <= 129) then
									if (Enum <= 127) then
										if (Enum > 126) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										else
											local FlatIdent_87A36 = 0;
											while true do
												if (FlatIdent_87A36 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_87A36 = 5;
												end
												if (FlatIdent_87A36 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
												if (FlatIdent_87A36 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_87A36 = 3;
												end
												if (FlatIdent_87A36 == 3) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_87A36 = 4;
												end
												if (FlatIdent_87A36 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_87A36 = 2;
												end
												if (FlatIdent_87A36 == 0) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_87A36 = 1;
												end
											end
										end
									elseif (Enum > 128) then
										local FlatIdent_39A50 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_39A50 == 1) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_39A50 = 2;
											end
											if (FlatIdent_39A50 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_39A50 = 1;
											end
											if (FlatIdent_39A50 == 12) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_39A50 = 13;
											end
											if (FlatIdent_39A50 == 7) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_39A50 = 8;
											end
											if (FlatIdent_39A50 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_39A50 = 3;
											end
											if (FlatIdent_39A50 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												FlatIdent_39A50 = 5;
											end
											if (6 == FlatIdent_39A50) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_39A50 = 7;
											end
											if (13 == FlatIdent_39A50) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_39A50 == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_39A50 = 12;
											end
											if (5 == FlatIdent_39A50) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_39A50 = 6;
											end
											if (9 == FlatIdent_39A50) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_39A50 = 10;
											end
											if (FlatIdent_39A50 == 8) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_39A50 = 9;
											end
											if (10 == FlatIdent_39A50) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_39A50 = 11;
											end
											if (FlatIdent_39A50 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_39A50 = 4;
											end
										end
									else
										local FlatIdent_54089 = 0;
										local A;
										while true do
											if (FlatIdent_54089 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_54089 = 7;
											end
											if (FlatIdent_54089 == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_54089 = 6;
											end
											if (FlatIdent_54089 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_54089 = 4;
											end
											if (FlatIdent_54089 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_54089 = 5;
											end
											if (FlatIdent_54089 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_54089 = 1;
											end
											if (FlatIdent_54089 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_54089 == 1) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_54089 = 2;
											end
											if (FlatIdent_54089 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_54089 = 3;
											end
										end
									end
								elseif (Enum <= 131) then
									if (Enum > 130) then
										local FlatIdent_59A9F = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_59A9F == 10) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_59A9F = 11;
											end
											if (FlatIdent_59A9F == 1) then
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_59A9F = 2;
											end
											if (FlatIdent_59A9F == 8) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_59A9F = 9;
											end
											if (FlatIdent_59A9F == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_59A9F = 1;
											end
											if (FlatIdent_59A9F == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_59A9F = 10;
											end
											if (FlatIdent_59A9F == 11) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_59A9F = 12;
											end
											if (FlatIdent_59A9F == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_59A9F = 3;
											end
											if (FlatIdent_59A9F == 12) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_59A9F == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_59A9F = 8;
											end
											if (FlatIdent_59A9F == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_59A9F = 5;
											end
											if (FlatIdent_59A9F == 5) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_59A9F = 6;
											end
											if (FlatIdent_59A9F == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_59A9F = 7;
											end
											if (FlatIdent_59A9F == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_59A9F = 4;
											end
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									end
								elseif (Enum <= 132) then
									local FlatIdent_4BC9C = 0;
									local A;
									while true do
										if (4 == FlatIdent_4BC9C) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 5;
										end
										if (FlatIdent_4BC9C == 0) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 1;
										end
										if (FlatIdent_4BC9C == 24) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 25;
										end
										if (26 == FlatIdent_4BC9C) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 27;
										end
										if (3 == FlatIdent_4BC9C) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_4BC9C = 4;
										end
										if (FlatIdent_4BC9C == 20) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 21;
										end
										if (FlatIdent_4BC9C == 9) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_4BC9C = 10;
										end
										if (FlatIdent_4BC9C == 12) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 13;
										end
										if (FlatIdent_4BC9C == 18) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 19;
										end
										if (FlatIdent_4BC9C == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_4BC9C = 11;
										end
										if (FlatIdent_4BC9C == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_4BC9C = 7;
										end
										if (FlatIdent_4BC9C == 23) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 24;
										end
										if (FlatIdent_4BC9C == 16) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4BC9C = 17;
										end
										if (FlatIdent_4BC9C == 13) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_4BC9C = 14;
										end
										if (FlatIdent_4BC9C == 19) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 20;
										end
										if (14 == FlatIdent_4BC9C) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 15;
										end
										if (5 == FlatIdent_4BC9C) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 6;
										end
										if (FlatIdent_4BC9C == 17) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4BC9C = 18;
										end
										if (FlatIdent_4BC9C == 15) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_4BC9C = 16;
										end
										if (FlatIdent_4BC9C == 21) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 22;
										end
										if (FlatIdent_4BC9C == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 9;
										end
										if (FlatIdent_4BC9C == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_4BC9C = 12;
										end
										if (1 == FlatIdent_4BC9C) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 2;
										end
										if (FlatIdent_4BC9C == 25) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 26;
										end
										if (FlatIdent_4BC9C == 27) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_4BC9C == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_4BC9C = 3;
										end
										if (FlatIdent_4BC9C == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4BC9C = 8;
										end
										if (FlatIdent_4BC9C == 22) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4BC9C = 23;
										end
									end
								elseif (Enum > 133) then
									local FlatIdent_E0FA = 0;
									local A;
									while true do
										if (FlatIdent_E0FA == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_E0FA = 1;
										end
										if (FlatIdent_E0FA == 7) then
											Stk[A](Stk[A + 1]);
											break;
										end
										if (FlatIdent_E0FA == 2) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_E0FA = 3;
										end
										if (FlatIdent_E0FA == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_E0FA = 4;
										end
										if (FlatIdent_E0FA == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_E0FA = 6;
										end
										if (1 == FlatIdent_E0FA) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_E0FA = 2;
										end
										if (FlatIdent_E0FA == 6) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_E0FA = 7;
										end
										if (FlatIdent_E0FA == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_E0FA = 5;
										end
									end
								elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 138) then
								if (Enum <= 136) then
									if (Enum == 135) then
										local K;
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
									else
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum > 137) then
									Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
								else
									local FlatIdent_722F2 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_722F2 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_722F2 = 5;
										end
										if (FlatIdent_722F2 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_722F2 = 6;
										end
										if (FlatIdent_722F2 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_722F2 = 2;
										end
										if (FlatIdent_722F2 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_722F2 = 1;
										end
										if (FlatIdent_722F2 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_722F2 = 3;
										end
										if (FlatIdent_722F2 == 6) then
											Stk[A] = B[Inst[4]];
											break;
										end
										if (3 == FlatIdent_722F2) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_722F2 = 4;
										end
									end
								end
							elseif (Enum <= 140) then
								if (Enum == 139) then
									local FlatIdent_887CE = 0;
									while true do
										if (FlatIdent_887CE == 3) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_887CE = 4;
										end
										if (FlatIdent_887CE == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_887CE = 2;
										end
										if (0 == FlatIdent_887CE) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_887CE = 1;
										end
										if (FlatIdent_887CE == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_887CE == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_887CE = 3;
										end
									end
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum <= 141) then
								local FlatIdent_54A3A = 0;
								local A;
								while true do
									if (5 == FlatIdent_54A3A) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_54A3A = 6;
									end
									if (FlatIdent_54A3A == 2) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_54A3A = 3;
									end
									if (FlatIdent_54A3A == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_54A3A = 2;
									end
									if (FlatIdent_54A3A == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_54A3A = 7;
									end
									if (FlatIdent_54A3A == 0) then
										A = nil;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_54A3A = 1;
									end
									if (FlatIdent_54A3A == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_54A3A = 5;
									end
									if (FlatIdent_54A3A == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_54A3A = 4;
									end
									if (FlatIdent_54A3A == 7) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							elseif (Enum > 142) then
								local FlatIdent_1D5BD = 0;
								local B;
								local T;
								local A;
								while true do
									if (FlatIdent_1D5BD == 2) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1D5BD = 3;
									end
									if (FlatIdent_1D5BD == 6) then
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
									if (FlatIdent_1D5BD == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1D5BD = 5;
									end
									if (FlatIdent_1D5BD == 0) then
										B = nil;
										T = nil;
										A = nil;
										FlatIdent_1D5BD = 1;
									end
									if (FlatIdent_1D5BD == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1D5BD = 2;
									end
									if (FlatIdent_1D5BD == 5) then
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										FlatIdent_1D5BD = 6;
									end
									if (FlatIdent_1D5BD == 3) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1D5BD = 4;
									end
								end
							else
								local FlatIdent_F1C3 = 0;
								local A;
								while true do
									if (FlatIdent_F1C3 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_F1C3 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_F1C3 = 1;
									end
									if (FlatIdent_F1C3 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_F1C3 = 2;
									end
									if (FlatIdent_F1C3 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_F1C3 = 3;
									end
									if (FlatIdent_F1C3 == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_F1C3 = 4;
									end
									if (FlatIdent_F1C3 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_F1C3 = 5;
									end
								end
							end
						elseif (Enum <= 215) then
							if (Enum <= 179) then
								if (Enum <= 161) then
									if (Enum <= 152) then
										if (Enum <= 147) then
											if (Enum <= 145) then
												if (Enum > 144) then
													Stk[Inst[2]]();
												else
													local FlatIdent_1C598 = 0;
													while true do
														if (FlatIdent_1C598 == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (1 == FlatIdent_1C598) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															FlatIdent_1C598 = 2;
														end
														if (FlatIdent_1C598 == 3) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_1C598 = 4;
														end
														if (FlatIdent_1C598 == 0) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															FlatIdent_1C598 = 1;
														end
														if (2 == FlatIdent_1C598) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_1C598 = 3;
														end
													end
												end
											elseif (Enum == 146) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
											else
												local A;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											end
										elseif (Enum <= 149) then
											if (Enum > 148) then
												local FlatIdent_3941F = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_3941F == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3941F = 1;
													end
													if (FlatIdent_3941F == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 3;
													end
													if (FlatIdent_3941F == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_3941F = 2;
													end
													if (14 == FlatIdent_3941F) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 15;
													end
													if (4 == FlatIdent_3941F) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_3941F = 5;
													end
													if (12 == FlatIdent_3941F) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3941F = 13;
													end
													if (FlatIdent_3941F == 8) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 9;
													end
													if (FlatIdent_3941F == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_3941F = 6;
													end
													if (FlatIdent_3941F == 17) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3941F = 18;
													end
													if (FlatIdent_3941F == 19) then
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														break;
													end
													if (FlatIdent_3941F == 3) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 4;
													end
													if (13 == FlatIdent_3941F) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3941F = 14;
													end
													if (FlatIdent_3941F == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3941F = 12;
													end
													if (FlatIdent_3941F == 15) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_3941F = 16;
													end
													if (7 == FlatIdent_3941F) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_3941F = 8;
													end
													if (FlatIdent_3941F == 16) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_3941F = 17;
													end
													if (9 == FlatIdent_3941F) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 10;
													end
													if (FlatIdent_3941F == 10) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														FlatIdent_3941F = 11;
													end
													if (6 == FlatIdent_3941F) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3941F = 7;
													end
													if (18 == FlatIdent_3941F) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3941F = 19;
													end
												end
											else
												local FlatIdent_10A91 = 0;
												local A;
												while true do
													if (FlatIdent_10A91 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_10A91 = 4;
													end
													if (FlatIdent_10A91 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_10A91 = 6;
													end
													if (FlatIdent_10A91 == 4) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														FlatIdent_10A91 = 5;
													end
													if (FlatIdent_10A91 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_10A91 = 9;
													end
													if (FlatIdent_10A91 == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_10A91 = 10;
													end
													if (FlatIdent_10A91 == 10) then
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_10A91 = 11;
													end
													if (FlatIdent_10A91 == 7) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_10A91 = 8;
													end
													if (1 == FlatIdent_10A91) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_10A91 = 2;
													end
													if (6 == FlatIdent_10A91) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_10A91 = 7;
													end
													if (FlatIdent_10A91 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
														VIP = VIP + 1;
														FlatIdent_10A91 = 3;
													end
													if (FlatIdent_10A91 == 0) then
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_10A91 = 1;
													end
													if (11 == FlatIdent_10A91) then
														if (Inst[2] < Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
												end
											end
										elseif (Enum <= 150) then
											local FlatIdent_77C1F = 0;
											local A;
											while true do
												if (FlatIdent_77C1F == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_77C1F = 3;
												end
												if (FlatIdent_77C1F == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_77C1F = 4;
												end
												if (FlatIdent_77C1F == 0) then
													A = nil;
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_77C1F = 1;
												end
												if (1 == FlatIdent_77C1F) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_77C1F = 2;
												end
												if (4 == FlatIdent_77C1F) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_77C1F = 5;
												end
												if (FlatIdent_77C1F == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
											end
										elseif (Enum == 151) then
											local FlatIdent_18888 = 0;
											local A;
											while true do
												if (FlatIdent_18888 == 4) then
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_18888 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_18888 = 3;
												end
												if (FlatIdent_18888 == 1) then
													A = Inst[2];
													Stk[A] = Stk[A]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_18888 = 2;
												end
												if (FlatIdent_18888 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_18888 = 4;
												end
												if (FlatIdent_18888 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_18888 = 1;
												end
											end
										else
											local FlatIdent_60A62 = 0;
											while true do
												if (FlatIdent_60A62 == 0) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_60A62 = 1;
												end
												if (FlatIdent_60A62 == 3) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_60A62 = 4;
												end
												if (FlatIdent_60A62 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_60A62 = 5;
												end
												if (FlatIdent_60A62 == 6) then
													do
														return Stk[Inst[2]];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_60A62 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_60A62 = 2;
												end
												if (2 == FlatIdent_60A62) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_60A62 = 3;
												end
												if (FlatIdent_60A62 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_60A62 = 6;
												end
											end
										end
									elseif (Enum <= 156) then
										if (Enum <= 154) then
											if (Enum == 153) then
												local FlatIdent_3DF45 = 0;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_3DF45 == 2) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_1F9E6 = 0;
															while true do
																if (FlatIdent_1F9E6 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_3DF45 = 3;
													end
													if (FlatIdent_3DF45 == 20) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 21;
													end
													if (FlatIdent_3DF45 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 9;
													end
													if (FlatIdent_3DF45 == 12) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_3DF45 = 13;
													end
													if (FlatIdent_3DF45 == 14) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 15;
													end
													if (FlatIdent_3DF45 == 7) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3DF45 = 8;
													end
													if (16 == FlatIdent_3DF45) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_3DF45 = 17;
													end
													if (FlatIdent_3DF45 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 4;
													end
													if (FlatIdent_3DF45 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 11;
													end
													if (FlatIdent_3DF45 == 24) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 25;
													end
													if (FlatIdent_3DF45 == 23) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 24;
													end
													if (FlatIdent_3DF45 == 6) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3DF45 = 7;
													end
													if (FlatIdent_3DF45 == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 14;
													end
													if (FlatIdent_3DF45 == 15) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3DF45 = 16;
													end
													if (FlatIdent_3DF45 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_3DF45 = 2;
													end
													if (FlatIdent_3DF45 == 11) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3DF45 = 12;
													end
													if (FlatIdent_3DF45 == 21) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_3DF45 = 22;
													end
													if (FlatIdent_3DF45 == 25) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_3DF45 == 18) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 19;
													end
													if (FlatIdent_3DF45 == 19) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 20;
													end
													if (FlatIdent_3DF45 == 22) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_3DF45 = 23;
													end
													if (FlatIdent_3DF45 == 4) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 5;
													end
													if (FlatIdent_3DF45 == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_3DF45 = 10;
													end
													if (FlatIdent_3DF45 == 17) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3DF45 = 18;
													end
													if (FlatIdent_3DF45 == 0) then
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_3DF45 = 1;
													end
													if (5 == FlatIdent_3DF45) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3DF45 = 6;
													end
												end
											else
												local FlatIdent_5ACCC = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_5ACCC == 3) then
														Upvalues[Inst[3]] = Stk[Inst[2]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5ACCC = 4;
													end
													if (4 == FlatIdent_5ACCC) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5ACCC = 5;
													end
													if (FlatIdent_5ACCC == 5) then
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_5ACCC == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5ACCC = 3;
													end
													if (FlatIdent_5ACCC == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_5ACCC = 2;
													end
													if (FlatIdent_5ACCC == 0) then
														B = nil;
														A = nil;
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_5ACCC = 1;
													end
												end
											end
										elseif (Enum == 155) then
											local FlatIdent_6D110 = 0;
											local B;
											local A;
											while true do
												if (4 == FlatIdent_6D110) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_6D110 = 5;
												end
												if (1 == FlatIdent_6D110) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6D110 = 2;
												end
												if (6 == FlatIdent_6D110) then
													Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
													break;
												end
												if (FlatIdent_6D110 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_6D110 = 1;
												end
												if (FlatIdent_6D110 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6D110 = 6;
												end
												if (FlatIdent_6D110 == 2) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_6D110 = 3;
												end
												if (FlatIdent_6D110 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_6D110 = 4;
												end
											end
										elseif (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 158) then
										if (Enum > 157) then
											local FlatIdent_15F81 = 0;
											local Edx;
											local Results;
											local A;
											while true do
												if (FlatIdent_15F81 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													FlatIdent_15F81 = 7;
												end
												if (FlatIdent_15F81 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_15F81 = 3;
												end
												if (FlatIdent_15F81 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Stk[A + 1])};
													Edx = 0;
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_15F81 = 10;
												end
												if (FlatIdent_15F81 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_15F81 = 6;
												end
												if (1 == FlatIdent_15F81) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_15F81 = 2;
												end
												if (7 == FlatIdent_15F81) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_15F81 = 8;
												end
												if (FlatIdent_15F81 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_15F81 = 5;
												end
												if (FlatIdent_15F81 == 3) then
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_15F81 = 4;
												end
												if (FlatIdent_15F81 == 10) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_15F81 == 0) then
													Edx = nil;
													Results = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_15F81 = 1;
												end
												if (FlatIdent_15F81 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_15F81 = 9;
												end
											end
										else
											local FlatIdent_91E5A = 0;
											local A;
											while true do
												if (FlatIdent_91E5A == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_91E5A = 1;
												end
												if (FlatIdent_91E5A == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_91E5A = 2;
												end
												if (11 == FlatIdent_91E5A) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_91E5A = 12;
												end
												if (FlatIdent_91E5A == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_91E5A = 3;
												end
												if (FlatIdent_91E5A == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													FlatIdent_91E5A = 10;
												end
												if (7 == FlatIdent_91E5A) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													FlatIdent_91E5A = 8;
												end
												if (5 == FlatIdent_91E5A) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_91E5A = 6;
												end
												if (FlatIdent_91E5A == 12) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_91E5A == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
													FlatIdent_91E5A = 11;
												end
												if (FlatIdent_91E5A == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_91E5A = 5;
												end
												if (FlatIdent_91E5A == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													FlatIdent_91E5A = 9;
												end
												if (FlatIdent_91E5A == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
													FlatIdent_91E5A = 7;
												end
												if (3 == FlatIdent_91E5A) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_91E5A = 4;
												end
											end
										end
									elseif (Enum <= 159) then
										local FlatIdent_496C9 = 0;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (2 == FlatIdent_496C9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Top));
												FlatIdent_496C9 = 3;
											end
											if (4 == FlatIdent_496C9) then
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_496C9 = 5;
											end
											if (FlatIdent_496C9 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_496C9 = 7;
											end
											if (FlatIdent_496C9 == 1) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_2B810 = 0;
													while true do
														if (0 == FlatIdent_2B810) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_496C9 = 2;
											end
											if (FlatIdent_496C9 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												FlatIdent_496C9 = 6;
											end
											if (7 == FlatIdent_496C9) then
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_496C9 = 8;
											end
											if (FlatIdent_496C9 == 8) then
												do
													return;
												end
												break;
											end
											if (FlatIdent_496C9 == 0) then
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_496C9 = 1;
											end
											if (FlatIdent_496C9 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_496C9 = 4;
											end
										end
									elseif (Enum > 160) then
										local FlatIdent_5DAF = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5DAF == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5DAF = 2;
											end
											if (FlatIdent_5DAF == 7) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 8;
											end
											if (FlatIdent_5DAF == 6) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 7;
											end
											if (FlatIdent_5DAF == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_5DAF = 10;
											end
											if (FlatIdent_5DAF == 3) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 4;
											end
											if (FlatIdent_5DAF == 8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5DAF = 9;
											end
											if (FlatIdent_5DAF == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_5DAF = 1;
											end
											if (FlatIdent_5DAF == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 3;
											end
											if (FlatIdent_5DAF == 10) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_5DAF == 5) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 6;
											end
											if (FlatIdent_5DAF == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5DAF = 5;
											end
										end
									else
										local FlatIdent_1529E = 0;
										local A;
										while true do
											if (FlatIdent_1529E == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1529E = 1;
											end
											if (FlatIdent_1529E == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] / Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1529E = 3;
											end
											if (FlatIdent_1529E == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_1529E = 4;
											end
											if (1 == FlatIdent_1529E) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1529E = 2;
											end
											if (FlatIdent_1529E == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Upvalues[Inst[3]] = Stk[Inst[2]];
												FlatIdent_1529E = 5;
											end
											if (5 == FlatIdent_1529E) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
										end
									end
								elseif (Enum <= 170) then
									if (Enum <= 165) then
										if (Enum <= 163) then
											if (Enum == 162) then
												local FlatIdent_54C62 = 0;
												local B;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_54C62 == 0) then
														B = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														A = Inst[2];
														FlatIdent_54C62 = 1;
													end
													if (FlatIdent_54C62 == 3) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_54C62 = 4;
													end
													if (FlatIdent_54C62 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_54C62 = 5;
													end
													if (FlatIdent_54C62 == 2) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_54C62 = 3;
													end
													if (FlatIdent_54C62 == 6) then
														Stk[A] = B[Inst[4]];
														break;
													end
													if (FlatIdent_54C62 == 1) then
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_5F14F = 0;
															while true do
																if (FlatIdent_5F14F == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														FlatIdent_54C62 = 2;
													end
													if (5 == FlatIdent_54C62) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_54C62 = 6;
													end
												end
											else
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											end
										elseif (Enum > 164) then
											local FlatIdent_53AE4 = 0;
											local A;
											while true do
												if (FlatIdent_53AE4 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_53AE4 = 5;
												end
												if (FlatIdent_53AE4 == 0) then
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_53AE4 = 1;
												end
												if (FlatIdent_53AE4 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_53AE4 = 2;
												end
												if (FlatIdent_53AE4 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_53AE4 = 3;
												end
												if (FlatIdent_53AE4 == 6) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_53AE4 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_53AE4 = 6;
												end
												if (FlatIdent_53AE4 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_53AE4 = 4;
												end
											end
										else
											local FlatIdent_1CF35 = 0;
											while true do
												if (FlatIdent_1CF35 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1CF35 = 2;
												end
												if (2 == FlatIdent_1CF35) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1CF35 = 3;
												end
												if (FlatIdent_1CF35 == 3) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1CF35 = 4;
												end
												if (FlatIdent_1CF35 == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_1CF35 == 0) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1CF35 = 1;
												end
											end
										end
									elseif (Enum <= 167) then
										if (Enum == 166) then
											local FlatIdent_3EC75 = 0;
											local B;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (6 == FlatIdent_3EC75) then
													Stk[A] = B[Inst[4]];
													break;
												end
												if (FlatIdent_3EC75 == 1) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_3EC75 = 2;
												end
												if (FlatIdent_3EC75 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_3EC75 = 6;
												end
												if (FlatIdent_3EC75 == 0) then
													B = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_3EC75 = 1;
												end
												if (FlatIdent_3EC75 == 2) then
													for Idx = A, Top do
														local FlatIdent_D701 = 0;
														while true do
															if (FlatIdent_D701 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3EC75 = 3;
												end
												if (FlatIdent_3EC75 == 3) then
													Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													FlatIdent_3EC75 = 4;
												end
												if (FlatIdent_3EC75 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_3EC75 = 5;
												end
											end
										else
											Stk[Inst[2]][Inst[3]] = Inst[4];
										end
									elseif (Enum <= 168) then
										local A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
									elseif (Enum > 169) then
										local FlatIdent_67B94 = 0;
										local A;
										while true do
											if (FlatIdent_67B94 == 17) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_67B94 = 18;
											end
											if (FlatIdent_67B94 == 22) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_67B94 = 23;
											end
											if (FlatIdent_67B94 == 7) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_67B94 = 8;
											end
											if (FlatIdent_67B94 == 15) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 16;
											end
											if (FlatIdent_67B94 == 11) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_67B94 = 12;
											end
											if (FlatIdent_67B94 == 1) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 2;
											end
											if (FlatIdent_67B94 == 24) then
												Stk[Inst[2]] = #Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_67B94 == 23) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 24;
											end
											if (20 == FlatIdent_67B94) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_67B94 = 21;
											end
											if (FlatIdent_67B94 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 7;
											end
											if (FlatIdent_67B94 == 10) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 11;
											end
											if (19 == FlatIdent_67B94) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 20;
											end
											if (FlatIdent_67B94 == 16) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_67B94 = 17;
											end
											if (FlatIdent_67B94 == 14) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 15;
											end
											if (FlatIdent_67B94 == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_67B94 = 3;
											end
											if (12 == FlatIdent_67B94) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_67B94 = 13;
											end
											if (FlatIdent_67B94 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_67B94 = 9;
											end
											if (FlatIdent_67B94 == 18) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_67B94 = 19;
											end
											if (FlatIdent_67B94 == 21) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_67B94 = 22;
											end
											if (FlatIdent_67B94 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_67B94 = 5;
											end
											if (FlatIdent_67B94 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_67B94 = 14;
											end
											if (FlatIdent_67B94 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_67B94 = 6;
											end
											if (FlatIdent_67B94 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_67B94 = 4;
											end
											if (FlatIdent_67B94 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_67B94 = 10;
											end
											if (0 == FlatIdent_67B94) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_67B94 = 1;
											end
										end
									else
										local FlatIdent_CAA8 = 0;
										local A;
										while true do
											if (FlatIdent_CAA8 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_CAA8 = 4;
											end
											if (FlatIdent_CAA8 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_CAA8 = 6;
											end
											if (FlatIdent_CAA8 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_CAA8 = 7;
											end
											if (FlatIdent_CAA8 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_CAA8 = 5;
											end
											if (0 == FlatIdent_CAA8) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_CAA8 = 1;
											end
											if (7 == FlatIdent_CAA8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_CAA8 = 8;
											end
											if (FlatIdent_CAA8 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_CAA8 = 2;
											end
											if (FlatIdent_CAA8 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_CAA8 = 3;
											end
											if (8 == FlatIdent_CAA8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
										end
									end
								elseif (Enum <= 174) then
									if (Enum <= 172) then
										if (Enum == 171) then
											local FlatIdent_4A191 = 0;
											while true do
												if (FlatIdent_4A191 == 1) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4A191 = 2;
												end
												if (FlatIdent_4A191 == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_4A191 == 0) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4A191 = 1;
												end
												if (FlatIdent_4A191 == 3) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4A191 = 4;
												end
												if (FlatIdent_4A191 == 2) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4A191 = 3;
												end
											end
										else
											Stk[Inst[2]] = Inst[3] / Stk[Inst[4]];
										end
									elseif (Enum > 173) then
										local FlatIdent_36BB7 = 0;
										local A;
										while true do
											if (1 == FlatIdent_36BB7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_36BB7 = 2;
											end
											if (FlatIdent_36BB7 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_36BB7 = 7;
											end
											if (FlatIdent_36BB7 == 0) then
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_36BB7 = 1;
											end
											if (FlatIdent_36BB7 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_36BB7 = 6;
											end
											if (FlatIdent_36BB7 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_36BB7 = 5;
											end
											if (FlatIdent_36BB7 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_36BB7 = 4;
											end
											if (FlatIdent_36BB7 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_36BB7 = 3;
											end
											if (FlatIdent_36BB7 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_36BB7 = 9;
											end
											if (FlatIdent_36BB7 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_36BB7 = 8;
											end
											if (9 == FlatIdent_36BB7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
										end
									else
										local FlatIdent_192B8 = 0;
										local K;
										local B;
										local A;
										while true do
											if (FlatIdent_192B8 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_192B8 = 2;
											end
											if (FlatIdent_192B8 == 0) then
												K = nil;
												B = nil;
												A = nil;
												FlatIdent_192B8 = 1;
											end
											if (FlatIdent_192B8 == 5) then
												Inst = Instr[VIP];
												B = Inst[3];
												K = Stk[B];
												FlatIdent_192B8 = 6;
											end
											if (7 == FlatIdent_192B8) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_192B8 = 8;
											end
											if (FlatIdent_192B8 == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_192B8 = 3;
											end
											if (FlatIdent_192B8 == 8) then
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_192B8 == 6) then
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												VIP = VIP + 1;
												FlatIdent_192B8 = 7;
											end
											if (FlatIdent_192B8 == 4) then
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_192B8 = 5;
											end
											if (FlatIdent_192B8 == 3) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_192B8 = 4;
											end
										end
									end
								elseif (Enum <= 176) then
									if (Enum > 175) then
										local FlatIdent_63B53 = 0;
										local B;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_63B53 == 3) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_63B53 = 4;
											end
											if (FlatIdent_63B53 == 1) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_6AA79 = 0;
													while true do
														if (FlatIdent_6AA79 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_63B53 = 2;
											end
											if (FlatIdent_63B53 == 6) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_63B53 == 0) then
												B = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_63B53 = 1;
											end
											if (FlatIdent_63B53 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_63B53 = 3;
											end
											if (FlatIdent_63B53 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_63B53 = 6;
											end
											if (FlatIdent_63B53 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_63B53 = 5;
											end
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = not Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 177) then
									local FlatIdent_3E5ED = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_3E5ED == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_3E5ED = 2;
										end
										if (2 == FlatIdent_3E5ED) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_3E5ED = 3;
										end
										if (FlatIdent_3E5ED == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_3E5ED = 5;
										end
										if (FlatIdent_3E5ED == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_3E5ED = 1;
										end
										if (3 == FlatIdent_3E5ED) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_3E5ED = 4;
										end
										if (FlatIdent_3E5ED == 5) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								elseif (Enum > 178) then
									local FlatIdent_36AA4 = 0;
									local A;
									while true do
										if (4 == FlatIdent_36AA4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_36AA4 = 5;
										end
										if (0 == FlatIdent_36AA4) then
											A = nil;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_36AA4 = 1;
										end
										if (FlatIdent_36AA4 == 5) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (2 == FlatIdent_36AA4) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_36AA4 = 3;
										end
										if (FlatIdent_36AA4 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_36AA4 = 4;
										end
										if (FlatIdent_36AA4 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_36AA4 = 2;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 197) then
								if (Enum <= 188) then
									if (Enum <= 183) then
										if (Enum <= 181) then
											if (Enum > 180) then
												for Idx = Inst[2], Inst[3] do
													Stk[Idx] = nil;
												end
											else
												local FlatIdent_292A3 = 0;
												local A;
												while true do
													if (FlatIdent_292A3 == 4) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_292A3 = 5;
													end
													if (FlatIdent_292A3 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_292A3 = 2;
													end
													if (FlatIdent_292A3 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (0 == FlatIdent_292A3) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_292A3 = 1;
													end
													if (FlatIdent_292A3 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_292A3 = 4;
													end
													if (FlatIdent_292A3 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_292A3 = 3;
													end
												end
											end
										elseif (Enum == 182) then
											local FlatIdent_5672E = 0;
											local A;
											while true do
												if (FlatIdent_5672E == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5672E = 3;
												end
												if (FlatIdent_5672E == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5672E = 1;
												end
												if (FlatIdent_5672E == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5672E = 2;
												end
												if (FlatIdent_5672E == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_5672E == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_5672E = 4;
												end
											end
										else
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
										end
									elseif (Enum <= 185) then
										if (Enum > 184) then
											local FlatIdent_20415 = 0;
											local B;
											local K;
											while true do
												if (FlatIdent_20415 == 1) then
													for Idx = B + 1, Inst[4] do
														K = K .. Stk[Idx];
													end
													Stk[Inst[2]] = K;
													break;
												end
												if (FlatIdent_20415 == 0) then
													B = Inst[3];
													K = Stk[B];
													FlatIdent_20415 = 1;
												end
											end
										else
											local FlatIdent_8C46B = 0;
											while true do
												if (4 == FlatIdent_8C46B) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_8C46B == 1) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8C46B = 2;
												end
												if (FlatIdent_8C46B == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8C46B = 3;
												end
												if (FlatIdent_8C46B == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8C46B = 4;
												end
												if (0 == FlatIdent_8C46B) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8C46B = 1;
												end
											end
										end
									elseif (Enum <= 186) then
										local FlatIdent_5C43E = 0;
										while true do
											if (FlatIdent_5C43E == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C43E = 3;
											end
											if (1 == FlatIdent_5C43E) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5C43E = 2;
											end
											if (FlatIdent_5C43E == 3) then
												Upvalues[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (0 == FlatIdent_5C43E) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5C43E = 1;
											end
										end
									elseif (Enum > 187) then
										local FlatIdent_14F1A = 0;
										local A;
										while true do
											if (FlatIdent_14F1A == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_14F1A = 3;
											end
											if (FlatIdent_14F1A == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												FlatIdent_14F1A = 4;
											end
											if (FlatIdent_14F1A == 5) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
											if (4 == FlatIdent_14F1A) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_14F1A = 5;
											end
											if (FlatIdent_14F1A == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_14F1A = 1;
											end
											if (FlatIdent_14F1A == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_14F1A = 2;
											end
										end
									else
										local FlatIdent_65150 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_65150 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_65150 = 2;
											end
											if (FlatIdent_65150 == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_65150 = 3;
											end
											if (4 == FlatIdent_65150) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_65150 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_65150 = 1;
											end
											if (FlatIdent_65150 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_65150 = 4;
											end
										end
									end
								elseif (Enum <= 192) then
									if (Enum <= 190) then
										if (Enum > 189) then
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										end
									elseif (Enum > 191) then
										local FlatIdent_3851C = 0;
										local K;
										local B;
										local A;
										while true do
											if (FlatIdent_3851C == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_3851C = 4;
											end
											if (FlatIdent_3851C == 16) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 17;
											end
											if (20 == FlatIdent_3851C) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3851C = 21;
											end
											if (FlatIdent_3851C == 22) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3851C = 23;
											end
											if (FlatIdent_3851C == 14) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3851C = 15;
											end
											if (FlatIdent_3851C == 13) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_3851C = 14;
											end
											if (FlatIdent_3851C == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3851C = 3;
											end
											if (FlatIdent_3851C == 12) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_3851C = 13;
											end
											if (FlatIdent_3851C == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 12;
											end
											if (FlatIdent_3851C == 5) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												B = Inst[3];
												FlatIdent_3851C = 6;
											end
											if (10 == FlatIdent_3851C) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3851C = 11;
											end
											if (9 == FlatIdent_3851C) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_3851C = 10;
											end
											if (FlatIdent_3851C == 6) then
												K = Stk[B];
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_3851C = 7;
											end
											if (0 == FlatIdent_3851C) then
												K = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_3851C = 1;
											end
											if (FlatIdent_3851C == 19) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3851C = 20;
											end
											if (FlatIdent_3851C == 15) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3851C = 16;
											end
											if (FlatIdent_3851C == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_3851C = 2;
											end
											if (FlatIdent_3851C == 18) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_3851C = 19;
											end
											if (FlatIdent_3851C == 17) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_3851C = 18;
											end
											if (FlatIdent_3851C == 8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 9;
											end
											if (FlatIdent_3851C == 23) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_3851C = 24;
											end
											if (FlatIdent_3851C == 24) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_3851C = 25;
											end
											if (FlatIdent_3851C == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 5;
											end
											if (FlatIdent_3851C == 21) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 22;
											end
											if (FlatIdent_3851C == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3851C = 8;
											end
											if (FlatIdent_3851C == 25) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
										end
									else
										local B;
										local A;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									end
								elseif (Enum <= 194) then
									if (Enum == 193) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									else
										Upvalues[Inst[3]] = Stk[Inst[2]];
									end
								elseif (Enum <= 195) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								elseif (Enum == 196) then
									local FlatIdent_8C19D = 0;
									local B;
									local A;
									while true do
										if (11 == FlatIdent_8C19D) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_8C19D == 3) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C19D = 4;
										end
										if (FlatIdent_8C19D == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_8C19D = 10;
										end
										if (FlatIdent_8C19D == 7) then
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_8C19D = 8;
										end
										if (10 == FlatIdent_8C19D) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_8C19D = 11;
										end
										if (FlatIdent_8C19D == 2) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_8C19D = 3;
										end
										if (FlatIdent_8C19D == 6) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C19D = 7;
										end
										if (FlatIdent_8C19D == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C19D = 2;
										end
										if (FlatIdent_8C19D == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8C19D = 9;
										end
										if (FlatIdent_8C19D == 5) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C19D = 6;
										end
										if (FlatIdent_8C19D == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C19D = 5;
										end
										if (FlatIdent_8C19D == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8C19D = 1;
										end
									end
								else
									local FlatIdent_210B8 = 0;
									while true do
										if (FlatIdent_210B8 == 4) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_210B8 = 5;
										end
										if (FlatIdent_210B8 == 3) then
											Stk[Inst[2]] = not Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_210B8 = 4;
										end
										if (FlatIdent_210B8 == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_210B8 = 2;
										end
										if (2 == FlatIdent_210B8) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_210B8 = 3;
										end
										if (FlatIdent_210B8 == 5) then
											do
												return;
											end
											break;
										end
										if (FlatIdent_210B8 == 0) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_210B8 = 1;
										end
									end
								end
							elseif (Enum <= 206) then
								if (Enum <= 201) then
									if (Enum <= 199) then
										if (Enum == 198) then
											local FlatIdent_3243F = 0;
											local A;
											while true do
												if (FlatIdent_3243F == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3243F = 2;
												end
												if (FlatIdent_3243F == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3243F = 6;
												end
												if (FlatIdent_3243F == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													break;
												end
												if (FlatIdent_3243F == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_3243F = 8;
												end
												if (FlatIdent_3243F == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3243F = 4;
												end
												if (2 == FlatIdent_3243F) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_3243F = 3;
												end
												if (FlatIdent_3243F == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_3243F = 1;
												end
												if (FlatIdent_3243F == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3243F = 9;
												end
												if (FlatIdent_3243F == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_3243F = 5;
												end
												if (FlatIdent_3243F == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_3243F = 7;
												end
											end
										else
											local A = Inst[2];
											local T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
										end
									elseif (Enum == 200) then
										local A = Inst[2];
										local Results = {Stk[A](Stk[A + 1])};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									else
										local FlatIdent_B82B = 0;
										local A;
										local Results;
										local Edx;
										while true do
											if (FlatIdent_B82B == 1) then
												Edx = 0;
												for Idx = A, Inst[4] do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												break;
											end
											if (FlatIdent_B82B == 0) then
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												FlatIdent_B82B = 1;
											end
										end
									end
								elseif (Enum <= 203) then
									if (Enum == 202) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										local FlatIdent_1523F = 0;
										local A;
										while true do
											if (1 == FlatIdent_1523F) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1523F = 2;
											end
											if (7 == FlatIdent_1523F) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_1523F == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1523F = 7;
											end
											if (FlatIdent_1523F == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1523F = 1;
											end
											if (FlatIdent_1523F == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1523F = 6;
											end
											if (FlatIdent_1523F == 2) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_1523F = 3;
											end
											if (FlatIdent_1523F == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1523F = 5;
											end
											if (FlatIdent_1523F == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1523F = 4;
											end
										end
									end
								elseif (Enum <= 204) then
									local FlatIdent_CFBE = 0;
									local T;
									local Results;
									local Limit;
									local Edx;
									local A;
									while true do
										if (FlatIdent_CFBE == 11) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_CFBE = 12;
										end
										if (FlatIdent_CFBE == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_CFBE = 3;
										end
										if (8 == FlatIdent_CFBE) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_CFBE = 9;
										end
										if (5 == FlatIdent_CFBE) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_CFBE = 6;
										end
										if (FlatIdent_CFBE == 6) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_CFBE = 7;
										end
										if (FlatIdent_CFBE == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_CFBE = 8;
										end
										if (14 == FlatIdent_CFBE) then
											A = Inst[2];
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_CFBE == 1) then
											for Idx = A, Inst[4] do
												local FlatIdent_93124 = 0;
												while true do
													if (FlatIdent_93124 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_CFBE = 2;
										end
										if (FlatIdent_CFBE == 13) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_21F92 = 0;
												while true do
													if (FlatIdent_21F92 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_CFBE = 14;
										end
										if (FlatIdent_CFBE == 4) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_CFBE = 5;
										end
										if (FlatIdent_CFBE == 0) then
											T = nil;
											Results, Limit = nil;
											Edx = nil;
											Results = nil;
											A = nil;
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											Edx = 0;
											FlatIdent_CFBE = 1;
										end
										if (10 == FlatIdent_CFBE) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_53EE6 = 0;
												while true do
													if (FlatIdent_53EE6 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											FlatIdent_CFBE = 11;
										end
										if (9 == FlatIdent_CFBE) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_5881 = 0;
												while true do
													if (0 == FlatIdent_5881) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_CFBE = 10;
										end
										if (12 == FlatIdent_CFBE) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_CFBE = 13;
										end
										if (FlatIdent_CFBE == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_CFBE = 4;
										end
									end
								elseif (Enum > 205) then
									local FlatIdent_4B05 = 0;
									local A;
									while true do
										if (FlatIdent_4B05 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_4B05 = 17;
										end
										if (FlatIdent_4B05 == 15) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4B05 = 16;
										end
										if (2 == FlatIdent_4B05) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_4B05 = 3;
										end
										if (FlatIdent_4B05 == 12) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4B05 = 13;
										end
										if (FlatIdent_4B05 == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4B05 = 11;
										end
										if (FlatIdent_4B05 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_4B05 = 9;
										end
										if (FlatIdent_4B05 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4B05 = 5;
										end
										if (FlatIdent_4B05 == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_4B05 = 7;
										end
										if (FlatIdent_4B05 == 13) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4B05 = 14;
										end
										if (FlatIdent_4B05 == 17) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_4B05 = 18;
										end
										if (FlatIdent_4B05 == 18) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return Stk[Inst[2]];
											end
											FlatIdent_4B05 = 19;
										end
										if (FlatIdent_4B05 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4B05 = 10;
										end
										if (FlatIdent_4B05 == 11) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4B05 = 12;
										end
										if (FlatIdent_4B05 == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4B05 = 1;
										end
										if (FlatIdent_4B05 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4B05 = 4;
										end
										if (FlatIdent_4B05 == 14) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4B05 = 15;
										end
										if (FlatIdent_4B05 == 19) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_4B05 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4B05 = 8;
										end
										if (1 == FlatIdent_4B05) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_4B05 = 2;
										end
										if (FlatIdent_4B05 == 5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4B05 = 6;
										end
									end
								else
									local FlatIdent_5F6C9 = 0;
									local A;
									local Cls;
									while true do
										if (FlatIdent_5F6C9 == 1) then
											for Idx = 1, #Lupvals do
												local FlatIdent_95112 = 0;
												local List;
												while true do
													if (FlatIdent_95112 == 0) then
														List = Lupvals[Idx];
														for Idz = 0, #List do
															local Upv = List[Idz];
															local NStk = Upv[1];
															local DIP = Upv[2];
															if ((NStk == Stk) and (DIP >= A)) then
																Cls[DIP] = NStk[DIP];
																Upv[1] = Cls;
															end
														end
														break;
													end
												end
											end
											break;
										end
										if (FlatIdent_5F6C9 == 0) then
											A = Inst[2];
											Cls = {};
											FlatIdent_5F6C9 = 1;
										end
									end
								end
							elseif (Enum <= 210) then
								if (Enum <= 208) then
									if (Enum > 207) then
										local FlatIdent_30F7E = 0;
										while true do
											if (FlatIdent_30F7E == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_30F7E = 2;
											end
											if (FlatIdent_30F7E == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_30F7E = 1;
											end
											if (FlatIdent_30F7E == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_30F7E = 3;
											end
											if (3 == FlatIdent_30F7E) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
										end
									else
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								elseif (Enum > 209) then
									local FlatIdent_68655 = 0;
									local A;
									while true do
										if (FlatIdent_68655 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_68655 = 3;
										end
										if (FlatIdent_68655 == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68655 = 1;
										end
										if (FlatIdent_68655 == 8) then
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_68655 = 9;
										end
										if (FlatIdent_68655 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
											VIP = VIP + 1;
											FlatIdent_68655 = 7;
										end
										if (FlatIdent_68655 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68655 = 8;
										end
										if (FlatIdent_68655 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_68655 = 2;
										end
										if (FlatIdent_68655 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68655 = 5;
										end
										if (FlatIdent_68655 == 11) then
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_68655 = 12;
										end
										if (FlatIdent_68655 == 5) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_68655 = 6;
										end
										if (10 == FlatIdent_68655) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68655 = 11;
										end
										if (FlatIdent_68655 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_68655 = 4;
										end
										if (FlatIdent_68655 == 12) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_68655 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = -Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_68655 = 10;
										end
									end
								else
									local FlatIdent_BA44 = 0;
									local A;
									while true do
										if (FlatIdent_BA44 == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_BA44 = 8;
										end
										if (FlatIdent_BA44 == 1) then
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_BA44 = 2;
										end
										if (9 == FlatIdent_BA44) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_BA44 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_BA44 = 9;
										end
										if (FlatIdent_BA44 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_BA44 = 3;
										end
										if (FlatIdent_BA44 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_BA44 = 7;
										end
										if (FlatIdent_BA44 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_BA44 = 5;
										end
										if (FlatIdent_BA44 == 5) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_BA44 = 6;
										end
										if (FlatIdent_BA44 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_BA44 = 4;
										end
										if (FlatIdent_BA44 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_BA44 = 1;
										end
									end
								end
							elseif (Enum <= 212) then
								if (Enum == 211) then
									local FlatIdent_65967 = 0;
									local A;
									while true do
										if (FlatIdent_65967 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_65967 = 7;
										end
										if (FlatIdent_65967 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_65967 = 3;
										end
										if (3 == FlatIdent_65967) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_65967 = 4;
										end
										if (FlatIdent_65967 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_65967 = 2;
										end
										if (FlatIdent_65967 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_65967 = 8;
										end
										if (FlatIdent_65967 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_65967 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_65967 = 6;
										end
										if (FlatIdent_65967 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_65967 = 9;
										end
										if (FlatIdent_65967 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_65967 = 1;
										end
										if (FlatIdent_65967 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_65967 = 5;
										end
									end
								else
									local FlatIdent_67D8F = 0;
									local A;
									while true do
										if (FlatIdent_67D8F == 0) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Top));
											break;
										end
									end
								end
							elseif (Enum <= 213) then
								local FlatIdent_6CFB8 = 0;
								while true do
									if (6 == FlatIdent_6CFB8) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										break;
									end
									if (FlatIdent_6CFB8 == 3) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 4;
									end
									if (FlatIdent_6CFB8 == 4) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 5;
									end
									if (0 == FlatIdent_6CFB8) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 1;
									end
									if (FlatIdent_6CFB8 == 5) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 6;
									end
									if (FlatIdent_6CFB8 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 3;
									end
									if (FlatIdent_6CFB8 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6CFB8 = 2;
									end
								end
							elseif (Enum == 214) then
								local FlatIdent_52C9A = 0;
								while true do
									if (FlatIdent_52C9A == 3) then
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_52C9A == 0) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_52C9A = 1;
									end
									if (2 == FlatIdent_52C9A) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_52C9A = 3;
									end
									if (FlatIdent_52C9A == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_52C9A = 2;
									end
								end
							else
								local FlatIdent_973C1 = 0;
								local A;
								while true do
									if (FlatIdent_973C1 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_973C1 = 2;
									end
									if (FlatIdent_973C1 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_973C1 = 1;
									end
									if (FlatIdent_973C1 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_973C1 = 8;
									end
									if (FlatIdent_973C1 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_973C1 = 6;
									end
									if (FlatIdent_973C1 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_973C1 = 4;
									end
									if (FlatIdent_973C1 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_973C1 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_973C1 = 5;
									end
									if (FlatIdent_973C1 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_973C1 = 7;
									end
									if (FlatIdent_973C1 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_973C1 = 9;
									end
									if (2 == FlatIdent_973C1) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_973C1 = 3;
									end
								end
							end
						elseif (Enum <= 251) then
							if (Enum <= 233) then
								if (Enum <= 224) then
									if (Enum <= 219) then
										if (Enum <= 217) then
											if (Enum > 216) then
												local FlatIdent_217BF = 0;
												local A;
												while true do
													if (FlatIdent_217BF == 0) then
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														break;
													end
												end
											else
												local FlatIdent_5A25E = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_5A25E == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_5A25E = 3;
													end
													if (FlatIdent_5A25E == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5A25E = 4;
													end
													if (FlatIdent_5A25E == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_5A25E = 6;
													end
													if (FlatIdent_5A25E == 6) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_5A25E = 7;
													end
													if (FlatIdent_5A25E == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5A25E = 8;
													end
													if (FlatIdent_5A25E == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_5A25E = 2;
													end
													if (FlatIdent_5A25E == 4) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_5A25E = 5;
													end
													if (0 == FlatIdent_5A25E) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5A25E = 1;
													end
													if (8 == FlatIdent_5A25E) then
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Upvalues[Inst[3]] = Stk[Inst[2]];
														break;
													end
												end
											end
										elseif (Enum == 218) then
											local FlatIdent_59D2A = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_59D2A == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_59D2A = 1;
												end
												if (FlatIdent_59D2A == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													FlatIdent_59D2A = 4;
												end
												if (FlatIdent_59D2A == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_59D2A = 5;
												end
												if (FlatIdent_59D2A == 5) then
													Inst = Instr[VIP];
													B = Stk[Inst[4]];
													if not B then
														VIP = VIP + 1;
													else
														local FlatIdent_7B9EA = 0;
														while true do
															if (FlatIdent_7B9EA == 0) then
																Stk[Inst[2]] = B;
																VIP = Inst[3];
																break;
															end
														end
													end
													break;
												end
												if (FlatIdent_59D2A == 2) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_59D2A = 3;
												end
												if (FlatIdent_59D2A == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_59D2A = 2;
												end
											end
										else
											local FlatIdent_4D759 = 0;
											local K;
											local B;
											local A;
											while true do
												if (FlatIdent_4D759 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_4D759 = 4;
												end
												if (FlatIdent_4D759 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_4D759 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_4D759 = 3;
												end
												if (FlatIdent_4D759 == 1) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_4D759 = 2;
												end
												if (FlatIdent_4D759 == 5) then
													Inst = Instr[VIP];
													B = Inst[3];
													K = Stk[B];
													for Idx = B + 1, Inst[4] do
														K = K .. Stk[Idx];
													end
													Stk[Inst[2]] = K;
													VIP = VIP + 1;
													FlatIdent_4D759 = 6;
												end
												if (4 == FlatIdent_4D759) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_4D759 = 5;
												end
												if (FlatIdent_4D759 == 0) then
													K = nil;
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4D759 = 1;
												end
											end
										end
									elseif (Enum <= 221) then
										if (Enum == 220) then
											local FlatIdent_77D27 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_77D27 == 6) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_77D27 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_77D27 = 4;
												end
												if (FlatIdent_77D27 == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_77D27 = 6;
												end
												if (FlatIdent_77D27 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_77D27 = 1;
												end
												if (FlatIdent_77D27 == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_77D27 = 3;
												end
												if (FlatIdent_77D27 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_77D27 = 5;
												end
												if (FlatIdent_77D27 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_77D27 = 2;
												end
											end
										else
											local FlatIdent_916AB = 0;
											local A;
											while true do
												if (FlatIdent_916AB == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													break;
												end
												if (3 == FlatIdent_916AB) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_916AB = 4;
												end
												if (FlatIdent_916AB == 2) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_916AB = 3;
												end
												if (FlatIdent_916AB == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_916AB = 2;
												end
												if (0 == FlatIdent_916AB) then
													A = nil;
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_916AB = 1;
												end
											end
										end
									elseif (Enum <= 222) then
										local FlatIdent_7957B = 0;
										while true do
											if (FlatIdent_7957B == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_7957B = 2;
											end
											if (0 == FlatIdent_7957B) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_7957B = 1;
											end
											if (FlatIdent_7957B == 3) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_7957B == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7957B = 3;
											end
										end
									elseif (Enum == 223) then
										local FlatIdent_91408 = 0;
										while true do
											if (FlatIdent_91408 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91408 = 4;
											end
											if (FlatIdent_91408 == 4) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91408 = 5;
											end
											if (FlatIdent_91408 == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91408 = 1;
											end
											if (FlatIdent_91408 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91408 = 2;
											end
											if (FlatIdent_91408 == 2) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91408 = 3;
											end
											if (FlatIdent_91408 == 5) then
												do
													return;
												end
												break;
											end
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									end
								elseif (Enum <= 228) then
									if (Enum <= 226) then
										if (Enum > 225) then
											local FlatIdent_47E7C = 0;
											local A;
											while true do
												if (FlatIdent_47E7C == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_47E7C = 7;
												end
												if (FlatIdent_47E7C == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_47E7C == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_47E7C = 2;
												end
												if (FlatIdent_47E7C == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_47E7C = 9;
												end
												if (FlatIdent_47E7C == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_47E7C = 8;
												end
												if (FlatIdent_47E7C == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_47E7C = 4;
												end
												if (FlatIdent_47E7C == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_47E7C = 1;
												end
												if (FlatIdent_47E7C == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_47E7C = 6;
												end
												if (FlatIdent_47E7C == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_47E7C = 5;
												end
												if (FlatIdent_47E7C == 2) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_47E7C = 3;
												end
											end
										else
											local FlatIdent_2911 = 0;
											local A;
											while true do
												if (FlatIdent_2911 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2911 = 9;
												end
												if (FlatIdent_2911 == 7) then
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_2911 = 8;
												end
												if (FlatIdent_2911 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2911 = 3;
												end
												if (FlatIdent_2911 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = -Stk[Inst[3]];
													FlatIdent_2911 = 6;
												end
												if (FlatIdent_2911 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2911 = 1;
												end
												if (FlatIdent_2911 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2911 = 7;
												end
												if (FlatIdent_2911 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2911 = 10;
												end
												if (FlatIdent_2911 == 10) then
													Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_2911 = 11;
												end
												if (1 == FlatIdent_2911) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = -Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2911 = 2;
												end
												if (FlatIdent_2911 == 4) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_2911 = 5;
												end
												if (FlatIdent_2911 == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2911 = 4;
												end
												if (FlatIdent_2911 == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
											end
										end
									elseif (Enum == 227) then
										local FlatIdent_75D76 = 0;
										local A;
										while true do
											if (FlatIdent_75D76 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75D76 = 1;
											end
											if (11 == FlatIdent_75D76) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75D76 = 12;
											end
											if (FlatIdent_75D76 == 12) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_75D76 = 13;
											end
											if (FlatIdent_75D76 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_75D76 = 4;
											end
											if (FlatIdent_75D76 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75D76 = 5;
											end
											if (7 == FlatIdent_75D76) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75D76 = 8;
											end
											if (FlatIdent_75D76 == 5) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_75D76 = 6;
											end
											if (FlatIdent_75D76 == 10) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_75D76 = 11;
											end
											if (FlatIdent_75D76 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_75D76 = 3;
											end
											if (FlatIdent_75D76 == 13) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_75D76 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_75D76 = 7;
											end
											if (FlatIdent_75D76 == 9) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_75D76 = 10;
											end
											if (FlatIdent_75D76 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_75D76 = 2;
											end
											if (FlatIdent_75D76 == 8) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_75D76 = 9;
											end
										end
									else
										local FlatIdent_7A47F = 0;
										local A;
										while true do
											if (FlatIdent_7A47F == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7A47F = 7;
											end
											if (2 == FlatIdent_7A47F) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7A47F = 3;
											end
											if (FlatIdent_7A47F == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7A47F = 2;
											end
											if (0 == FlatIdent_7A47F) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7A47F = 1;
											end
											if (FlatIdent_7A47F == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7A47F = 4;
											end
											if (FlatIdent_7A47F == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_7A47F = 5;
											end
											if (FlatIdent_7A47F == 7) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_7A47F == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7A47F = 6;
											end
										end
									end
								elseif (Enum <= 230) then
									if (Enum == 229) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum <= 231) then
									local FlatIdent_13936 = 0;
									local A;
									while true do
										if (6 == FlatIdent_13936) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_13936 = 7;
										end
										if (FlatIdent_13936 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_13936 = 2;
										end
										if (FlatIdent_13936 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_13936 = 6;
										end
										if (FlatIdent_13936 == 0) then
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_13936 = 1;
										end
										if (7 == FlatIdent_13936) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_13936 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_13936 = 5;
										end
										if (FlatIdent_13936 == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_13936 = 3;
										end
										if (FlatIdent_13936 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_13936 = 4;
										end
									end
								elseif (Enum > 232) then
									local FlatIdent_28142 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_28142 == 15) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_28142 = 16;
										end
										if (FlatIdent_28142 == 14) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 15;
										end
										if (FlatIdent_28142 == 17) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 18;
										end
										if (FlatIdent_28142 == 10) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 11;
										end
										if (12 == FlatIdent_28142) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 13;
										end
										if (FlatIdent_28142 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_28142 = 17;
										end
										if (FlatIdent_28142 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 9;
										end
										if (9 == FlatIdent_28142) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_28142 = 10;
										end
										if (18 == FlatIdent_28142) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_28142 = 19;
										end
										if (FlatIdent_28142 == 20) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28142 = 21;
										end
										if (FlatIdent_28142 == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_28142 = 2;
										end
										if (FlatIdent_28142 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_28142 = 8;
										end
										if (FlatIdent_28142 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_28142 = 5;
										end
										if (FlatIdent_28142 == 21) then
											Stk[A](Stk[A + 1]);
											break;
										end
										if (FlatIdent_28142 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_28142 = 3;
										end
										if (FlatIdent_28142 == 19) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_28142 = 20;
										end
										if (FlatIdent_28142 == 11) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_28142 = 12;
										end
										if (FlatIdent_28142 == 13) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28142 = 14;
										end
										if (FlatIdent_28142 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 1;
										end
										if (FlatIdent_28142 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28142 = 4;
										end
										if (FlatIdent_28142 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28142 = 6;
										end
										if (FlatIdent_28142 == 6) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_28142 = 7;
										end
									end
								else
									local FlatIdent_3BBDA = 0;
									local B;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (6 == FlatIdent_3BBDA) then
											Stk[A] = B[Inst[4]];
											break;
										end
										if (3 == FlatIdent_3BBDA) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3BBDA = 4;
										end
										if (FlatIdent_3BBDA == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3BBDA = 3;
										end
										if (4 == FlatIdent_3BBDA) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_3BBDA = 5;
										end
										if (FlatIdent_3BBDA == 0) then
											B = nil;
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											A = Inst[2];
											FlatIdent_3BBDA = 1;
										end
										if (1 == FlatIdent_3BBDA) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											FlatIdent_3BBDA = 2;
										end
										if (FlatIdent_3BBDA == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_3BBDA = 6;
										end
									end
								end
							elseif (Enum <= 242) then
								if (Enum <= 237) then
									if (Enum <= 235) then
										if (Enum > 234) then
											local FlatIdent_297C4 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_297C4 == 6) then
													Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
													break;
												end
												if (FlatIdent_297C4 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_297C4 = 2;
												end
												if (FlatIdent_297C4 == 2) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_297C4 = 3;
												end
												if (FlatIdent_297C4 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_297C4 = 1;
												end
												if (FlatIdent_297C4 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_297C4 = 6;
												end
												if (FlatIdent_297C4 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_297C4 = 5;
												end
												if (3 == FlatIdent_297C4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_297C4 = 4;
												end
											end
										else
											local B;
											local T;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										end
									elseif (Enum == 236) then
										local FlatIdent_8F7DB = 0;
										local B;
										while true do
											if (FlatIdent_8F7DB == 0) then
												B = Stk[Inst[4]];
												if not B then
													VIP = VIP + 1;
												else
													local FlatIdent_26BC6 = 0;
													while true do
														if (0 == FlatIdent_26BC6) then
															Stk[Inst[2]] = B;
															VIP = Inst[3];
															break;
														end
													end
												end
												break;
											end
										end
									else
										Stk[Inst[2]] = Inst[3] ~= 0;
									end
								elseif (Enum <= 239) then
									if (Enum == 238) then
										local FlatIdent_9258E = 0;
										while true do
											if (FlatIdent_9258E == 3) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_9258E = 4;
											end
											if (FlatIdent_9258E == 0) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_9258E = 1;
											end
											if (FlatIdent_9258E == 4) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_9258E = 5;
											end
											if (FlatIdent_9258E == 1) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_9258E = 2;
											end
											if (5 == FlatIdent_9258E) then
												Stk[Inst[2]] = Env[Inst[3]];
												break;
											end
											if (FlatIdent_9258E == 2) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_9258E = 3;
											end
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] ^ Inst[4];
									end
								elseif (Enum <= 240) then
									if (Inst[2] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 241) then
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									local FlatIdent_697CC = 0;
									local Edx;
									local Results;
									local A;
									while true do
										if (FlatIdent_697CC == 5) then
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (1 == FlatIdent_697CC) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
											FlatIdent_697CC = 2;
										end
										if (FlatIdent_697CC == 3) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_697CC = 4;
										end
										if (FlatIdent_697CC == 2) then
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_41AE3 = 0;
												while true do
													if (FlatIdent_41AE3 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_697CC = 3;
										end
										if (FlatIdent_697CC == 0) then
											Edx = nil;
											Results = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_697CC = 1;
										end
										if (FlatIdent_697CC == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_697CC = 5;
										end
									end
								end
							elseif (Enum <= 246) then
								if (Enum <= 244) then
									if (Enum > 243) then
										local FlatIdent_72232 = 0;
										while true do
											if (FlatIdent_72232 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_72232 = 2;
											end
											if (FlatIdent_72232 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_72232 = 5;
											end
											if (2 == FlatIdent_72232) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_72232 = 3;
											end
											if (FlatIdent_72232 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												FlatIdent_72232 = 4;
											end
											if (7 == FlatIdent_72232) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if (Stk[Inst[2]] <= Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_72232 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_72232 = 6;
											end
											if (FlatIdent_72232 == 0) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_72232 = 1;
											end
											if (FlatIdent_72232 == 6) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_72232 = 7;
											end
										end
									else
										Stk[Inst[2]] = -Stk[Inst[3]];
									end
								elseif (Enum > 245) then
									Stk[Inst[2]] = Inst[3];
								else
									local FlatIdent_692EE = 0;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (0 == FlatIdent_692EE) then
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											Stk[Inst[2]] = Inst[3];
											FlatIdent_692EE = 1;
										end
										if (FlatIdent_692EE == 8) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_692EE == 4) then
											for Idx = A, Top do
												local FlatIdent_1A843 = 0;
												while true do
													if (FlatIdent_1A843 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_692EE = 5;
										end
										if (FlatIdent_692EE == 3) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_692EE = 4;
										end
										if (FlatIdent_692EE == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_692EE = 8;
										end
										if (FlatIdent_692EE == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_692EE = 7;
										end
										if (FlatIdent_692EE == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_692EE = 2;
										end
										if (FlatIdent_692EE == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_692EE = 3;
										end
										if (FlatIdent_692EE == 5) then
											Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_692EE = 6;
										end
									end
								end
							elseif (Enum <= 248) then
								if (Enum == 247) then
									do
										return;
									end
								else
									local B;
									local T;
									local A;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								end
							elseif (Enum <= 249) then
								local FlatIdent_5F897 = 0;
								local B;
								local Edx;
								local Results;
								local Limit;
								local A;
								while true do
									if (7 == FlatIdent_5F897) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_5F897 = 8;
									end
									if (FlatIdent_5F897 == 8) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_5F897 == 1) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_5F897 = 2;
									end
									if (FlatIdent_5F897 == 6) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										FlatIdent_5F897 = 7;
									end
									if (FlatIdent_5F897 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5F897 = 6;
									end
									if (0 == FlatIdent_5F897) then
										B = nil;
										Edx = nil;
										Results, Limit = nil;
										A = nil;
										FlatIdent_5F897 = 1;
									end
									if (FlatIdent_5F897 == 2) then
										for Idx = A, Top do
											local FlatIdent_1C44E = 0;
											while true do
												if (FlatIdent_1C44E == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_5F897 = 3;
									end
									if (FlatIdent_5F897 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_5F897 = 5;
									end
									if (3 == FlatIdent_5F897) then
										Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_5F897 = 4;
									end
								end
							elseif (Enum > 250) then
								local FlatIdent_84867 = 0;
								local B;
								local A;
								while true do
									if (6 == FlatIdent_84867) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_84867 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84867 = 5;
									end
									if (FlatIdent_84867 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84867 = 2;
									end
									if (FlatIdent_84867 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_84867 = 1;
									end
									if (FlatIdent_84867 == 3) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_84867 = 4;
									end
									if (FlatIdent_84867 == 5) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84867 = 6;
									end
									if (FlatIdent_84867 == 2) then
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_84867 = 3;
									end
								end
							else
								local FlatIdent_1F7AC = 0;
								local Edx;
								local Results;
								local Limit;
								local A;
								while true do
									if (FlatIdent_1F7AC == 3) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_1F7AC = 4;
									end
									if (0 == FlatIdent_1F7AC) then
										Edx = nil;
										Results, Limit = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_1F7AC = 1;
									end
									if (1 == FlatIdent_1F7AC) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_1F7AC = 2;
									end
									if (FlatIdent_1F7AC == 5) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										FlatIdent_1F7AC = 6;
									end
									if (FlatIdent_1F7AC == 4) then
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_2B395 = 0;
											while true do
												if (FlatIdent_2B395 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1F7AC = 5;
									end
									if (2 == FlatIdent_1F7AC) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1F7AC = 3;
									end
									if (FlatIdent_1F7AC == 7) then
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_1F7AC == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_1F7AC = 7;
									end
								end
							end
						elseif (Enum <= 269) then
							if (Enum <= 260) then
								if (Enum <= 255) then
									if (Enum <= 253) then
										if (Enum > 252) then
											local FlatIdent_513D9 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_513D9 == 6) then
													Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
													break;
												end
												if (FlatIdent_513D9 == 2) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_513D9 = 3;
												end
												if (FlatIdent_513D9 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_513D9 = 4;
												end
												if (FlatIdent_513D9 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_513D9 = 6;
												end
												if (FlatIdent_513D9 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_513D9 = 5;
												end
												if (1 == FlatIdent_513D9) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_513D9 = 2;
												end
												if (FlatIdent_513D9 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_513D9 = 1;
												end
											end
										else
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = not Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum > 254) then
										Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									else
										local FlatIdent_5E25C = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5E25C == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_5E25C = 2;
											end
											if (FlatIdent_5E25C == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_5E25C = 5;
											end
											if (FlatIdent_5E25C == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5E25C = 1;
											end
											if (FlatIdent_5E25C == 3) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_5E25C = 4;
											end
											if (FlatIdent_5E25C == 5) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5E25C = 6;
											end
											if (FlatIdent_5E25C == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5E25C = 3;
											end
											if (6 == FlatIdent_5E25C) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5E25C = 7;
											end
											if (FlatIdent_5E25C == 7) then
												do
													return;
												end
												break;
											end
										end
									end
								elseif (Enum <= 257) then
									if (Enum > 256) then
										local FlatIdent_70EDB = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_70EDB == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_70EDB = 4;
											end
											if (FlatIdent_70EDB == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_70EDB = 6;
											end
											if (FlatIdent_70EDB == 1) then
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_70EDB = 2;
											end
											if (4 == FlatIdent_70EDB) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_1E62C = 0;
													while true do
														if (0 == FlatIdent_1E62C) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_70EDB = 5;
											end
											if (FlatIdent_70EDB == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_70EDB = 3;
											end
											if (6 == FlatIdent_70EDB) then
												for Idx = A, Inst[4] do
													local FlatIdent_701DC = 0;
													while true do
														if (0 == FlatIdent_701DC) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_70EDB == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_70EDB = 1;
											end
										end
									else
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum <= 258) then
									local FlatIdent_2532E = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (1 == FlatIdent_2532E) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_2532E = 2;
										end
										if (FlatIdent_2532E == 2) then
											for Idx = A, Top do
												local FlatIdent_78E3C = 0;
												while true do
													if (FlatIdent_78E3C == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
										if (FlatIdent_2532E == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_2532E = 1;
										end
									end
								elseif (Enum > 259) then
									local FlatIdent_652EE = 0;
									local B;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_652EE == 2) then
											Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_652EE = 3;
										end
										if (FlatIdent_652EE == 1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_306A4 = 0;
												while true do
													if (FlatIdent_306A4 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_652EE = 2;
										end
										if (FlatIdent_652EE == 4) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_652EE = 5;
										end
										if (FlatIdent_652EE == 6) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_652EE == 5) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_652EE = 6;
										end
										if (FlatIdent_652EE == 3) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_652EE = 4;
										end
										if (FlatIdent_652EE == 0) then
											B = nil;
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_652EE = 1;
										end
									end
								else
									local FlatIdent_53B7B = 0;
									local A;
									while true do
										if (FlatIdent_53B7B == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_53B7B = 5;
										end
										if (FlatIdent_53B7B == 5) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_53B7B = 6;
										end
										if (FlatIdent_53B7B == 0) then
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_53B7B = 1;
										end
										if (FlatIdent_53B7B == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_53B7B = 3;
										end
										if (FlatIdent_53B7B == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_53B7B == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_53B7B = 2;
										end
										if (6 == FlatIdent_53B7B) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_53B7B = 7;
										end
										if (FlatIdent_53B7B == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_53B7B = 4;
										end
									end
								end
							elseif (Enum <= 264) then
								if (Enum <= 262) then
									if (Enum > 261) then
										local FlatIdent_97807 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_97807 == 19) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 20;
											end
											if (FlatIdent_97807 == 8) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_97807 = 9;
											end
											if (FlatIdent_97807 == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 12;
											end
											if (FlatIdent_97807 == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 23;
											end
											if (FlatIdent_97807 == 14) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_97807 = 15;
											end
											if (FlatIdent_97807 == 10) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_97807 = 11;
											end
											if (FlatIdent_97807 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 1;
											end
											if (FlatIdent_97807 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_97807 = 2;
											end
											if (FlatIdent_97807 == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_97807 = 4;
											end
											if (FlatIdent_97807 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_97807 = 7;
											end
											if (23 == FlatIdent_97807) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_97807 == 12) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_97807 = 13;
											end
											if (FlatIdent_97807 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 10;
											end
											if (FlatIdent_97807 == 18) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_97807 = 19;
											end
											if (FlatIdent_97807 == 16) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 17;
											end
											if (FlatIdent_97807 == 5) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_97807 = 6;
											end
											if (FlatIdent_97807 == 20) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_97807 = 21;
											end
											if (FlatIdent_97807 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 3;
											end
											if (FlatIdent_97807 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 14;
											end
											if (FlatIdent_97807 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 8;
											end
											if (FlatIdent_97807 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97807 = 5;
											end
											if (17 == FlatIdent_97807) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_97807 = 18;
											end
											if (21 == FlatIdent_97807) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_97807 = 22;
											end
											if (FlatIdent_97807 == 15) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_97807 = 16;
											end
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
									end
								elseif (Enum > 263) then
									local FlatIdent_62804 = 0;
									local A;
									while true do
										if (FlatIdent_62804 == 0) then
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_62804 = 1;
										end
										if (FlatIdent_62804 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_62804 = 2;
										end
										if (FlatIdent_62804 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_62804 = 4;
										end
										if (FlatIdent_62804 == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_62804 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_62804 = 5;
										end
										if (FlatIdent_62804 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_62804 = 3;
										end
									end
								else
									local FlatIdent_6E1DD = 0;
									local A;
									while true do
										if (FlatIdent_6E1DD == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_6E1DD = 6;
										end
										if (2 == FlatIdent_6E1DD) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
											VIP = VIP + 1;
											FlatIdent_6E1DD = 3;
										end
										if (FlatIdent_6E1DD == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_6E1DD = 5;
										end
										if (FlatIdent_6E1DD == 7) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_6E1DD == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											FlatIdent_6E1DD = 4;
										end
										if (FlatIdent_6E1DD == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6E1DD = 2;
										end
										if (FlatIdent_6E1DD == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_6E1DD = 1;
										end
										if (FlatIdent_6E1DD == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6E1DD = 7;
										end
									end
								end
							elseif (Enum <= 266) then
								if (Enum > 265) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								else
									local FlatIdent_6B3D6 = 0;
									local A;
									while true do
										if (3 == FlatIdent_6B3D6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6B3D6 = 4;
										end
										if (FlatIdent_6B3D6 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6B3D6 = 5;
										end
										if (FlatIdent_6B3D6 == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_6B3D6 = 8;
										end
										if (FlatIdent_6B3D6 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_6B3D6 = 7;
										end
										if (9 == FlatIdent_6B3D6) then
											VIP = Inst[3];
											break;
										end
										if (5 == FlatIdent_6B3D6) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_6B3D6 = 6;
										end
										if (FlatIdent_6B3D6 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6B3D6 = 1;
										end
										if (FlatIdent_6B3D6 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_6B3D6 = 3;
										end
										if (FlatIdent_6B3D6 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6B3D6 = 9;
										end
										if (FlatIdent_6B3D6 == 1) then
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] * Stk[Inst[4]];
											FlatIdent_6B3D6 = 2;
										end
									end
								end
							elseif (Enum <= 267) then
								local FlatIdent_7BE0E = 0;
								while true do
									if (FlatIdent_7BE0E == 6) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_7BE0E == 3) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_7BE0E = 4;
									end
									if (FlatIdent_7BE0E == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_7BE0E = 5;
									end
									if (FlatIdent_7BE0E == 0) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_7BE0E = 1;
									end
									if (FlatIdent_7BE0E == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7BE0E = 6;
									end
									if (2 == FlatIdent_7BE0E) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7BE0E = 3;
									end
									if (1 == FlatIdent_7BE0E) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_7BE0E = 2;
									end
								end
							elseif (Enum > 268) then
								Stk[Inst[2]] = not Stk[Inst[3]];
							else
								local FlatIdent_6AB86 = 0;
								local A;
								while true do
									if (FlatIdent_6AB86 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_6AB86 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_6AB86 = 6;
									end
									if (FlatIdent_6AB86 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_6AB86 = 7;
									end
									if (FlatIdent_6AB86 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_6AB86 = 3;
									end
									if (FlatIdent_6AB86 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6AB86 = 1;
									end
									if (3 == FlatIdent_6AB86) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_6AB86 = 4;
									end
									if (FlatIdent_6AB86 == 1) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6AB86 = 2;
									end
									if (FlatIdent_6AB86 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6AB86 = 5;
									end
								end
							end
						elseif (Enum <= 278) then
							if (Enum <= 273) then
								if (Enum <= 271) then
									if (Enum == 270) then
										Stk[Inst[2]] = Stk[Inst[3]];
									else
										local FlatIdent_2EFA7 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_2EFA7 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_2EFA7 = 1;
											end
											if (FlatIdent_2EFA7 == 6) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_2EFA7 = 7;
											end
											if (FlatIdent_2EFA7 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_2EFA7 = 6;
											end
											if (FlatIdent_2EFA7 == 1) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_2EFA7 = 2;
											end
											if (FlatIdent_2EFA7 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_2EFA7 = 4;
											end
											if (FlatIdent_2EFA7 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_2EFA7 = 3;
											end
											if (FlatIdent_2EFA7 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_2EFA7 = 5;
											end
											if (FlatIdent_2EFA7 == 7) then
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									end
								elseif (Enum > 272) then
									local FlatIdent_12A89 = 0;
									while true do
										if (FlatIdent_12A89 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_12A89 = 3;
										end
										if (3 == FlatIdent_12A89) then
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_12A89 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_12A89 = 2;
										end
										if (FlatIdent_12A89 == 0) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_12A89 = 1;
										end
									end
								else
									local FlatIdent_55ADC = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_55ADC == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_55ADC = 1;
										end
										if (1 == FlatIdent_55ADC) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								end
							elseif (Enum <= 275) then
								if (Enum == 274) then
									local FlatIdent_594A3 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_594A3 == 6) then
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_594A3 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_594A3 = 2;
										end
										if (FlatIdent_594A3 == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_594A3 = 6;
										end
										if (FlatIdent_594A3 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_594A3 = 1;
										end
										if (FlatIdent_594A3 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_594A3 = 4;
										end
										if (FlatIdent_594A3 == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_594A3 = 3;
										end
										if (FlatIdent_594A3 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_594A3 = 5;
										end
									end
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 276) then
								if (Stk[Inst[2]] <= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 277) then
								local FlatIdent_50EE3 = 0;
								local Edx;
								local Results;
								local A;
								while true do
									if (FlatIdent_50EE3 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_50EE3 = 3;
									end
									if (3 == FlatIdent_50EE3) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_50EE3 = 4;
									end
									if (6 == FlatIdent_50EE3) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_50EE3 = 7;
									end
									if (FlatIdent_50EE3 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_50EE3 = 6;
									end
									if (FlatIdent_50EE3 == 7) then
										Results = {Stk[A](Stk[A + 1])};
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_43A55 = 0;
											while true do
												if (FlatIdent_43A55 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										FlatIdent_50EE3 = 8;
									end
									if (FlatIdent_50EE3 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_50EE3 = 5;
									end
									if (FlatIdent_50EE3 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_50EE3 = 2;
									end
									if (FlatIdent_50EE3 == 0) then
										Edx = nil;
										Results = nil;
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_50EE3 = 1;
									end
									if (FlatIdent_50EE3 == 8) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							end
						elseif (Enum <= 282) then
							if (Enum <= 280) then
								if (Enum == 279) then
									local FlatIdent_33537 = 0;
									local B;
									local A;
									while true do
										if (6 == FlatIdent_33537) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33537 = 7;
										end
										if (FlatIdent_33537 == 12) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
										if (FlatIdent_33537 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33537 = 1;
										end
										if (FlatIdent_33537 == 11) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_33537 = 12;
										end
										if (FlatIdent_33537 == 7) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_33537 = 8;
										end
										if (FlatIdent_33537 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33537 = 5;
										end
										if (10 == FlatIdent_33537) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_33537 = 11;
										end
										if (FlatIdent_33537 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_33537 = 6;
										end
										if (8 == FlatIdent_33537) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_33537 = 9;
										end
										if (FlatIdent_33537 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_33537 = 4;
										end
										if (2 == FlatIdent_33537) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33537 = 3;
										end
										if (FlatIdent_33537 == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_33537 = 2;
										end
										if (9 == FlatIdent_33537) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_33537 = 10;
										end
									end
								else
									local FlatIdent_8F6BF = 0;
									local NewProto;
									local NewUvals;
									local Indexes;
									while true do
										if (FlatIdent_8F6BF == 1) then
											Indexes = {};
											NewUvals = Setmetatable({}, {[LUAOBFUSACTOR_DECRYPT_STR_0("\28\242\35\203\248\38\213", "\156\67\173\74\165")]=function(_, Key)
												local FlatIdent_2A258 = 0;
												local Val;
												while true do
													if (FlatIdent_2A258 == 0) then
														Val = Indexes[Key];
														return Val[1][Val[2]];
													end
												end
											end,[LUAOBFUSACTOR_DECRYPT_STR_0("\11\136\71\19\171\47\72\48\178\81", "\38\84\215\41\118\220\70")]=function(_, Key, Value)
												local FlatIdent_6F683 = 0;
												local Val;
												while true do
													if (0 == FlatIdent_6F683) then
														Val = Indexes[Key];
														Val[1][Val[2]] = Value;
														break;
													end
												end
											end});
											FlatIdent_8F6BF = 2;
										end
										if (FlatIdent_8F6BF == 0) then
											NewProto = Proto[Inst[3]];
											NewUvals = nil;
											FlatIdent_8F6BF = 1;
										end
										if (FlatIdent_8F6BF == 2) then
											for Idx = 1, Inst[4] do
												local FlatIdent_4636C = 0;
												local Mvm;
												while true do
													if (FlatIdent_4636C == 0) then
														VIP = VIP + 1;
														Mvm = Instr[VIP];
														FlatIdent_4636C = 1;
													end
													if (FlatIdent_4636C == 1) then
														if (Mvm[1] == 270) then
															Indexes[Idx - 1] = {Stk,Mvm[3]};
														else
															Indexes[Idx - 1] = {Upvalues,Mvm[3]};
														end
														Lupvals[#Lupvals + 1] = Indexes;
														break;
													end
												end
											end
											Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
											break;
										end
									end
								end
							elseif (Enum == 281) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_282AF = 0;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_282AF) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_282AF = 3;
									end
									if (FlatIdent_282AF == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_282AF = 2;
									end
									if (FlatIdent_282AF == 3) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_282AF = 4;
									end
									if (FlatIdent_282AF == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_282AF = 5;
									end
									if (FlatIdent_282AF == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_282AF = 1;
									end
									if (FlatIdent_282AF == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Upvalues[Inst[3]] = Stk[Inst[2]];
										break;
									end
								end
							end
						elseif (Enum <= 284) then
							if (Enum > 283) then
								Stk[Inst[2]] = {};
							else
								local FlatIdent_18900 = 0;
								local A;
								while true do
									if (FlatIdent_18900 == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_18900 = 3;
									end
									if (FlatIdent_18900 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_18900 = 2;
									end
									if (4 == FlatIdent_18900) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_18900 = 5;
									end
									if (FlatIdent_18900 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_18900 = 4;
									end
									if (FlatIdent_18900 == 5) then
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										break;
									end
									if (FlatIdent_18900 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_18900 = 1;
									end
								end
							end
						elseif (Enum <= 285) then
							local FlatIdent_1B45D = 0;
							while true do
								if (4 == FlatIdent_1B45D) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_1B45D = 5;
								end
								if (FlatIdent_1B45D == 5) then
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_1B45D == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1B45D = 3;
								end
								if (FlatIdent_1B45D == 0) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1B45D = 1;
								end
								if (FlatIdent_1B45D == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_1B45D = 2;
								end
								if (FlatIdent_1B45D == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1B45D = 4;
								end
							end
						elseif (Enum > 286) then
							local FlatIdent_4E781 = 0;
							local A;
							while true do
								if (FlatIdent_4E781 == 11) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 12;
								end
								if (FlatIdent_4E781 == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_4E781 = 1;
								end
								if (FlatIdent_4E781 == 16) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_4E781 = 17;
								end
								if (FlatIdent_4E781 == 31) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									break;
								end
								if (FlatIdent_4E781 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_4E781 = 3;
								end
								if (4 == FlatIdent_4E781) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_4E781 = 5;
								end
								if (FlatIdent_4E781 == 28) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_4E781 = 29;
								end
								if (FlatIdent_4E781 == 15) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_4E781 = 16;
								end
								if (FlatIdent_4E781 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_4E781 = 2;
								end
								if (FlatIdent_4E781 == 12) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4E781 = 13;
								end
								if (FlatIdent_4E781 == 22) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 23;
								end
								if (26 == FlatIdent_4E781) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 27;
								end
								if (FlatIdent_4E781 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 8;
								end
								if (FlatIdent_4E781 == 8) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4E781 = 9;
								end
								if (FlatIdent_4E781 == 24) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 25;
								end
								if (FlatIdent_4E781 == 29) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4E781 = 30;
								end
								if (FlatIdent_4E781 == 25) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4E781 = 26;
								end
								if (FlatIdent_4E781 == 30) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_4E781 = 31;
								end
								if (FlatIdent_4E781 == 20) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 21;
								end
								if (FlatIdent_4E781 == 13) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_4E781 = 14;
								end
								if (FlatIdent_4E781 == 6) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_4E781 = 7;
								end
								if (FlatIdent_4E781 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_4E781 = 4;
								end
								if (27 == FlatIdent_4E781) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4E781 = 28;
								end
								if (FlatIdent_4E781 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 6;
								end
								if (FlatIdent_4E781 == 17) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_4E781 = 18;
								end
								if (10 == FlatIdent_4E781) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4E781 = 11;
								end
								if (FlatIdent_4E781 == 19) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_4E781 = 20;
								end
								if (FlatIdent_4E781 == 9) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 10;
								end
								if (14 == FlatIdent_4E781) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4E781 = 15;
								end
								if (21 == FlatIdent_4E781) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_4E781 = 22;
								end
								if (FlatIdent_4E781 == 18) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_4E781 = 19;
								end
								if (FlatIdent_4E781 == 23) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4E781 = 24;
								end
							end
						else
							local FlatIdent_12925 = 0;
							while true do
								if (FlatIdent_12925 == 0) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12925 = 1;
								end
								if (FlatIdent_12925 == 3) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12925 = 4;
								end
								if (FlatIdent_12925 == 4) then
									Stk[Inst[2]] = Env[Inst[3]];
									break;
								end
								if (FlatIdent_12925 == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12925 = 2;
								end
								if (FlatIdent_12925 == 2) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12925 = 3;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_29127 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_29127 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!34012Q0003043Q0067616D65030A3Q004765745365727669636503073Q00506C6179657273030A3Q0052756E5365727669636503073Q00436F726547756903103Q0055736572496E70757453657276696365030C3Q0054772Q656E5365727669636503083Q004C69676874696E67030D3Q0053746172746572506C61796572030C3Q00536F756E6453657276696365030B3Q004C6F63616C506C6179657203073Q003Q5F53544B5F03083Q00746F737472696E6703043Q006D61746803063Q0072616E646F6D025Q00408F40024Q008087C34003053Q0047722Q656E03063Q00436F6C6F723303073Q0066726F6D524742028Q00025Q00E06F40026Q0059402Q033Q00526564026Q00494003043Q00426C7565025Q00C0624003063Q0059652Q6C6F7703063Q00507572706C65026Q00644003053Q00576869746503053Q00426C61636B03053Q00526164617203073Q00456E61626C65642Q0103053Q00436F6C6F722Q033Q00524742010003053Q005363616C65026Q00F03F03083Q00506F736974696F6E03083Q00546F70204C65667403063Q004B6579485544030E3Q004261636B6C69676874436F6C6F72030C3Q004261636B6C6967687452474203093Q0054657874436F6C6F7203073Q00546578745247422Q033Q0045535003093Q005465616D436865636B03053Q004E616D657303053Q00426F78657303083Q00426F78436F6C6F7203063Q00426F7852474203093Q0057612Q6C436865636B03073Q00547261636572732Q033Q0047554903073Q0053686F7746505303083Q00465053436F6C6F7203063Q0046505352474203073Q0046502Q53697A65026Q00304003053Q00576F726C64030A3Q0046752Q6C627269676874030A3Q0053617475726174696F6E03083Q00436F6E74726173742Q033Q00466F67025Q0088C34003083Q00465053422Q6F737403073Q00496E664A756D70030F3Q0054656C65706F7274456E61626C6564030B3Q0054656C65706F72744B657903043Q00456E756D03073Q004B6579436F646503013Q005A030D3Q004D6178545044697374616E636503103Q0057616C6B53702Q6564456E61626C6564030E3Q0057616C6B53702Q656456616C756503053Q00417564696F03063Q00566F6C756D6503053Q00506974636803063Q005265766572622Q033Q00464F56025Q0080564003093Q00546F2Q676C654B657903073Q004C656674416C74030C3Q007365746D6574617461626C6503063Q002Q5F6D6F646503013Q006B03093Q00776F726B737061636503053Q007461626C6503063Q00696E7365727403183Q0047657450726F70657274794368616E6765645369676E616C030D3Q0043752Q72656E7443616D65726103073Q00436F2Q6E656374030E3Q0046696E6446697273744368696C64030A3Q005354414C4B45525F2Q4303083Q00496E7374616E63652Q033Q006E657703153Q00436F6C6F72436F2Q72656374696F6E452Q6665637403043Q004E616D65030C3Q005354414C4B45525F426C7572030A3Q00426C7572452Q6665637403043Q0053697A6503093Q005363722Q656E477569030C3Q0052657365744F6E537061776E030E3Q0049676E6F7265477569496E73657403053Q007063612Q6C03063Q00506172656E74030C3Q0057616974466F724368696C6403093Q00506C61796572477569026Q002440030A3Q005465787442752Q746F6E03053Q005544696D3203163Q004261636B67726F756E645472616E73706172656E637903043Q0054657874034Q0003073Q0056697369626C6503053Q004D6F64616C03063Q005A496E64657803093Q00546578744C6162656C030A3Q0066726F6D4F2Q66736574026Q006940026Q003E40025Q00806BC0026Q00144003073Q004650533A202Q2D03043Q00466F6E7403043Q00436F646503083Q005465787453697A65030A3Q0054657874436F6C6F7233030E3Q005465787458416C69676E6D656E7403053Q005269676874030D3Q0052656E6465725374652Q70656403043Q007461736B03053Q00737061776E030B3Q0043616E76617347726F7570025Q002Q9040025Q00907A40026Q00E03F025Q009080C0025Q003081C003103Q004261636B67726F756E64436F6C6F7233026Q003840026Q003A4003113Q0047726F75705472616E73706172656E637903083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D030A3Q0055494772616469656E74030D3Q00436F6C6F7253657175656E636503153Q00436F6C6F7253657175656E63654B6579706F696E74026Q003240026Q003C40026Q002Q4003083Q00526F746174696F6E025Q0080464003053Q004672616D65026Q002E40026Q0041C0030F3Q00426F7264657253697A65506978656C026Q002840026Q00104003023Q006677030A3Q00476F7468616D426F6C6403063Q0043656E746572030E3Q005465787459416C69676E6D656E74026Q002A40026Q003640025Q008044C0026Q003FC0025Q0080664003013Q005803113Q004D6F75736542752Q746F6E31436C69636B025Q00406040025Q00606840026Q005E40025Q00406F40026Q003B4003263Q009Q202Q20464C4F4154574152452Q202Q2F2Q2046722Q652045646974696F6E030A3Q00467265646F6B614F6E6503043Q004C65667403103Q00546578745472616E73706172656E6379026Q007940026Q003440026Q0069C0026Q003DC003063Q00557365723A20030E3Q00476F7468616D53656D69626F6C64025Q00806140026Q00264003103Q00547261636B696E672026205261646172031B3Q0056697375616C732026205363722Q656E20496E64696361746F7273025Q00206C4003193Q00456E7669726F6E6D656E74202620506572666F726D616E6365025Q00307B4003143Q00417564696F20456E67696E652053797374656D73025Q0028844003103Q004D6F76656D656E742053797374656D73025Q00B88A40025Q00C0524003073Q00546F2Q676C657303073Q00536C6964657273025Q00207C40025Q00206CC0026Q004DC0033B3Q00446973636F7264204C696E6B20436F7069656421204A6F696E20666F722068656C702C207265717565737473206F722070757263686173696E6721026Q005640025Q00405940025Q00406E40025Q00804B40025Q00805EC003073Q00446973636F7264029A5Q99D93F030B3Q00416E63686F72506F696E7403073Q00566563746F7232025Q00C0594003013Q0057026Q004240025Q0080474003013Q0041026Q00184003013Q005303013Q004403053Q0053706163652Q033Q003Q5F025Q00805D40025Q00805540026Q002040030A3Q00496E707574426567616E030A3Q00496E707574456E646564030D3Q00526164617220456E61626C6564025Q0080414003093Q00526164617220524742030B3Q00526164617220436F6C6F72026Q00544003093Q00526164617220506F73025Q00405A4003093Q00546F70205269676874030B3Q00426F2Q746F6D204C656674030C3Q00426F2Q746F6D205269676874030B3Q005261646172205363616C65027Q0040030B3Q0045535020456E61626C6564025Q00E0654003073Q0045535020524742030E3Q00455350205465616D20436865636B025Q00E06A40030E3Q004553502057612Q6C20436865636B025Q00606D4003093Q00455350204E616D657303073Q00426F7820455350025Q0030714003073Q00426F7820524742025Q0070724003093Q00426F7820436F6C6F72026Q00744003093Q0045535020436F6C6F72025Q00907540030F3Q005472616365727320456E61626C6564030B3Q00547261636572732052474203123Q0054726163657273205465616D20436865636B030D3Q005472616365727320436F6C6F72030D3Q004669656C64206F662056696577025Q00C05740027Q00C0025Q00E0604003083Q0053686F772046505303073Q004650532052474203093Q0046505320436F6C6F72025Q00806B40030D3Q0046505320546578742053697A65025Q00A06E40030B3Q0046505320422Q6F73746572025Q00D07140030D3Q004D617374657220566F6C756D65030E3Q00506C61796261636B205069746368029A5Q99B93F026Q000840030D3Q00456E61626C6520526576657262025Q00C05C4003113Q00496E66696E69746520416972204A756D7003153Q004D6F7573652D546F2D54656C65706F7274204B6579026Q004E40025Q00405F40026Q004F40030B3Q004D61782054502044697374025Q00405540025Q00407F4003103Q00456E61626C652057616C6B53702Q6564030D3Q0057616C6B53702Q6564204D6F6403163Q004D6F76656D656E745761726E696E674F7665726C6179025Q00206740025Q00807640026Q33C33F030F3Q004175746F42752Q746F6E436F6C6F72026Q004440026Q0030C0034A3Q005761726E696E673A205573696E6720746865736520636865617473206D617920726573756C7420696E20646574656374696F6E20646570656E64696E67206F6E207468652067616D6521030B3Q00546578745772612Q706564025Q00804440025Q008051C0026Q004340030F3Q00412Q63657074202620556E6C6F636B025Q00C06C40026Q004540025Q00806AC0030E3Q00506C6179657252656D6F76696E67030B3Q004A756D7052657175657374006C072Q00120F3Q00013Q00206Q000200122Q000200038Q0002000200122Q000100013Q00202Q00010001000200122Q000300046Q00010003000200122Q000200013Q00202Q00020002000200122Q000400056Q00020004000200122Q000300013Q00202Q00030003000200122Q000500066Q00030005000200122Q000400013Q00202Q00040004000200122Q000600076Q00040006000200122Q000500013Q00202Q00050005000200122Q000700086Q00050007000200122Q000600013Q00202Q00060006000200122Q000800096Q00060008000200122Q000700013Q00202Q00070007000200122Q0009000A6Q00070009000200202Q00083Q000B00122Q0009000C3Q00122Q000A000D3Q00122Q000B000E3Q00202Q000B000B000F00122Q000C00103Q00122Q000D00116Q000B000D6Q000A3Q00024Q00090009000A4Q000A8Q000B8Q000C3Q000700122Q000D00133Q00202Q000D000D001400122Q000E00153Q00122Q000F00163Q00122Q001000176Q000D0010000200102Q000C0012000D00122Q000D00133Q00202Q000D000D001400122Q000E00163Q00122Q000F00193Q00122Q001000196Q000D0010000200102Q000C0018000D00122Q000D00133Q00202Q000D000D001400122Q000E00193Q00122Q000F001B3Q00122Q001000166Q000D0010000200102Q000C001A000D00122Q000D00133Q00202Q000D000D001400122Q000E00163Q00122Q000F00163Q00122Q001000156Q000D0010000200102Q000C001C000D00122Q000D00133Q00202Q000D000D001400122Q000E001E3Q00122Q000F00193Q00122Q001000166Q000D0010000200102Q000C001D000D00128C000D00133Q002060000D000D001400122Q000E00163Q00122Q000F00163Q00122Q001000166Q000D001000020010C1000C001F000D00128C000D00133Q002060000D000D001400122Q000E00153Q00122Q000F00153Q00122Q001000156Q000D001000020010AB000C0020000D4Q000D3Q00094Q000E3Q000500302Q000E0022002300122Q000F00133Q002060000F000F001400122Q0010001E3Q00122Q001100193Q00122Q001200166Q000F00120002001000010E0024000F00302Q000E0025002600302Q000E0027002800302Q000E0029002A00102Q000D0021000E4Q000E3Q000600302Q000E0022002300302Q000E0027002800202Q000F000C002000102Q000E002C000F0030A7000E002D002600206E000F000C001D00102Q000E002E000F00302Q000E002F002600102Q000D002B000E4Q000E3Q000900302Q000E0022002300202Q000F000C001F00102Q000E0024000F00302Q000E0025002600302Q000E003100230030A7000E00320023003015000E0033002300202Q000F000C001800102Q000E0034000F00302Q000E0035002600302Q000E0036002600102Q000D0030000E4Q000E3Q000400302Q000E0022002600122Q000F00133Q002060000F000F001400122Q001000193Q00122Q0011001B3Q00122Q001200166Q000F001200020010EE000E0024000F00302Q000E0025002600302Q000E0031002600102Q000D0037000E4Q000E3Q000600122Q000F00133Q002060000F000F001400122Q0010001E3Q00122Q001100193Q00122Q001200166Q000F0012000200100E000E0024000F00302Q000E0025002600302Q000E0039002600202Q000F000C001F00102Q000E003A000F00302Q000E003B002600302Q000E003C003D00102Q000D0038000E4Q000E3Q000B00302Q000E003F00260030A7000E0040001500300B010E0041001500302Q000E0042004300302Q000E0044002600302Q000E0045002600302Q000E0046002600122Q000F00483Q00202Q000F000F004900202Q000F000F004A00102Q000E0047000F00302Q000E004B00190030A7000E004C002600307E000E004D003D00102Q000D003E000E4Q000E3Q000300302Q000E004F001900302Q000E0050002800302Q000E0051002600102Q000D004E000E00302Q000D0052005300121E010E00483Q00202Q000E000E004900202Q000E000E005500102Q000D0054000E00122Q000E00564Q007B000F8Q00103Q000100302Q0010005700584Q000E0010000200122Q000F00566Q00108Q00113Q000100302Q0011005700584Q000F0011000200061801103Q000100042Q000E012Q000E4Q000E012Q000D4Q000E012Q000B4Q000E012Q000F3Q00061801110001000100042Q000E012Q000D4Q000E012Q00074Q000E017Q000E012Q00103Q00061801120002000100022Q000E012Q00104Q000E012Q000B4Q0086001300123Q00122Q001400596Q0013000200014Q001300126Q001400076Q0013000200014Q001300126Q00148Q00130002000100061801130003000100022Q000E012Q000D4Q000E012Q000A3Q00124F0014005A3Q00202Q00140014005B4Q0015000A3Q00122Q001600593Q00202Q00160016005C00122Q0018005D6Q00160018000200202Q00160016005E00061801180004000100012Q000E012Q00134Q0004011600186Q00143Q00014Q001400133Q00122Q001500593Q00202Q00150015005D4Q00140002000100202Q00140005005F00122Q001600606Q00140016000200062Q001400F500010001000413012Q00F5000100128C001400613Q0020340014001400620012F6001500634Q000E011600054Q00710014001600020030A700140064006000201001150005005F0012F6001700654Q007100150017000200065100152Q002Q010001000413013Q002Q0100128C001500613Q0020340015001500620012F6001600664Q000E011700054Q00710015001700020030A700150064006500306400150067001500302Q00150022002300122Q001600613Q00202Q00160016006200122Q001700686Q00160002000200102Q00160064000900302Q00160069002600302Q0016006A002300122Q0017006B3Q00061801180005000100022Q000E012Q00164Q000E012Q00024Q00C800170002001800064E001700142Q013Q000413012Q00142Q0100203400190016006C000651001900192Q010001000413012Q00192Q0100201001190008006D0012F6001B006E3Q0012F6001C006F4Q00710019001C00020010C10016006C001900128C001900613Q00200601190019006200122Q001A00706Q001B00166Q0019001B000200122Q001A00713Q00202Q001A001A006200122Q001B00283Q00122Q001C00153Q00122Q001D00283Q00122Q001E00156Q001A001E000200102Q00190067001A00302Q00190072002800302Q00190073007400302Q00190075002600302Q00190076002600302Q00190077002800122Q001A00613Q00202Q001A001A006200122Q001B00786Q001C00166Q001A001C000200122Q001B00713Q00202Q001B001B007900122Q001C007A3Q00122Q001D007B6Q001B001D000200102Q001A0067001B00122Q001B00713Q00202Q001B001B006200122Q001C00283Q00122Q001D007C3Q00122Q001E00153Q00122Q001F007D6Q001B001F000200102Q001A0029001B00302Q001A0072002800302Q001A0073007E00122Q001B00483Q00202Q001B001B007F00202Q001B001B008000102Q001A007F001B00202Q001B000D003800202Q001B001B003C00102Q001A0081001B00202Q001B000D003800202Q001B001B003A00102Q001A0082001B00122Q001B00483Q00202Q001B001B008300202Q001B001B008400102Q001A0083001B00302Q001A0075002600302Q001A0077007D00122Q001B00153Q00122Q001C005A3Q00202Q001C001C005B4Q001D000A3Q00202Q001E0001008500202Q001E001E005E00061801200006000100012Q000E012Q001B4Q0002011E00204Q00D4001C3Q000100128C001C00863Q002034001C001C0087000618011D0007000100032Q000E012Q00164Q000E012Q001A4Q000E012Q001B4Q00DD001C000200014Q001C8Q001D8Q001E8Q001F8Q00205Q00061801210008000100052Q000E012Q001C4Q000E012Q001D4Q000E012Q001E4Q000E012Q001F4Q000E012Q00203Q00061801220009000100022Q000E012Q00054Q000E012Q000D3Q0006180123000A0001000F2Q000E012Q000B4Q000E012Q000A4Q000E012Q00054Q000E012Q00144Q000E012Q00154Q000E017Q000E012Q00214Q000E012Q000D4Q000E012Q00224Q000E012Q00074Q000E012Q000E4Q000E012Q000F4Q000E012Q00084Q000E012Q00064Q000E012Q00163Q001207002400613Q00202Q00240024006200122Q002500886Q002600166Q00240026000200122Q002500713Q00202Q00250025007900122Q002600893Q00122Q0027008A6Q00250027000200102Q00240067002500122Q002500713Q00202Q00250025006200122Q0026008B3Q00122Q0027008C3Q00122Q002800153Q00122Q0029008D6Q00250029000200102Q00240029002500122Q002500133Q00202Q00250025001400122Q0026008F3Q00122Q0027008F3Q00122Q002800906Q00250028000200102Q0024008E002500302Q00240091002800302Q00240077006F00122Q002500613Q00202Q00250025006200122Q002600926Q002700246Q00250027000200122Q002600943Q00202Q00260026006200122Q002700153Q00122Q0028006F6Q00260028000200102Q00250093002600122Q002500613Q00202Q00250025006200122Q002600956Q002700246Q00250027000200122Q002600963Q00202Q0026002600624Q002700013Q00122Q002800973Q00202Q00280028006200122Q002900153Q00122Q002A00133Q00202Q002A002A001400122Q002B003D3Q00122Q002C003D3Q00122Q002D00986Q002A002D6Q00283Q000200122Q002900973Q00202Q00290029006200122Q002A00283Q00122Q002B00133Q00202Q002B002B001400122Q002C00993Q00122Q002D00993Q00122Q002E009A6Q002B002E6Q00298Q00273Q00012Q000A00260002000200108400250024002600302Q0025009B009C00122Q002600613Q00202Q00260026006200122Q0027009D6Q002800246Q00260028000200122Q002700713Q00202Q00270027007900122Q0028008F3Q00122Q0029008F6Q00270029000200102Q00260067002700122Q002700713Q00202Q00270027006200122Q002800153Q00122Q0029009E3Q00122Q002A00283Q00122Q002B009F6Q0027002B000200102Q00260029002700122Q002700133Q00202Q00270027001400122Q002800163Q00122Q002900163Q00122Q002A00166Q0027002A000200102Q0026008E002700302Q002600A0001500302Q0026007700A100122Q002700613Q00202Q00270027006200122Q002800926Q002900266Q00270029000200122Q002800943Q00202Q00280028006200122Q002900153Q00122Q002A00A26Q0028002A000200102Q00270093002800122Q002700613Q00202Q00270027006200122Q002800786Q002900266Q00270029000200122Q002800713Q00202Q00280028006200122Q002900283Q00122Q002A00153Q00122Q002B00283Q00122Q002C00156Q0028002C000200102Q00270067002800302Q00270072002800302Q0027007300A300122Q002800483Q00202Q00280028007F00202Q0028002800A400102Q0027007F002800302Q0027008100A100122Q002800133Q00202Q00280028001400122Q0029009E3Q00122Q002A009E3Q00122Q002B003D6Q0028002B000200102Q00270082002800122Q002800483Q00202Q00280028008300202Q0028002800A500102Q00270083002800122Q002800483Q00202Q0028002800A600202Q0028002800A500102Q002700A6002800302Q0027007700A700122Q002800613Q00202Q00280028006200122Q002900704Q000E012A00244Q00230028002A000200122Q002900713Q00202Q00290029007900122Q002A00903Q00122Q002B00A86Q0029002B000200102Q00280067002900122Q002900713Q00202Q00290029006200122Q002A00283Q00122Q002B00A93Q00122Q002C00283Q00122Q002D00AA6Q0029002D000200102Q00280029002900122Q002900133Q00202Q00290029001400122Q002A00AB3Q00122Q002B00193Q00122Q002C00196Q0029002C000200102Q0028008E002900302Q0028007300AC00122Q002900133Q00202Q00290029006200122Q002A00283Q00122Q002B00283Q00122Q002C00286Q0029002C000200102Q00280082002900122Q002900483Q00202Q00290029007F00202Q0029002900A400102Q0028007F002900302Q0028008100A100302Q00280077001900122Q002900613Q00202Q00290029006200122Q002A00926Q002B00286Q0029002B000200122Q002A00943Q00202Q002A002A006200122Q002B00153Q00122Q002C00A26Q002A002C000200102Q00290093002A00202Q0029002800AD00202Q00290029005E4Q002B00236Q0029002B000100122Q002900133Q00202Q00290029001400122Q002A00AE3Q00122Q002B007B3Q00122Q002C00166Q0029002C000200122Q002A00133Q00202Q002A002A001400122Q002B00AF3Q00122Q002C00B03Q00122Q002D00166Q002A002D000200122Q002B00613Q00202Q002B002B006200122Q002C00786Q002D00246Q002B002D000200122Q002C00713Q00202Q002C002C007900122Q002D00B13Q00122Q002E00B26Q002C002E000200102Q002B0067002C00122Q002C00713Q00202Q002C002C006200122Q002D00153Q00122Q002E009E3Q00122Q002F00283Q00122Q0030009F4Q00AE002C0030000200102Q002B0029002C00302Q002B0072002800302Q002B007300B300122Q002C00483Q00202Q002C002C007F00202Q002C002C00B400102Q002B007F002C00302Q002B0081009E00102Q002B008200290012D5002C00483Q00202Q002C002C008300202Q002C002C00B500102Q002B0083002C00302Q002B007700A700122Q002C00613Q00202Q002C002C00620012F6002D00784Q000E012E00244Q0071002C002E0002002034002D002B00670010C1002C0067002D00207F002D002B002900102Q002C0029002D00302Q002C0072002800202Q002D002B007300102Q002C0073002D00202Q002D002B007F00102Q002C007F002D00202Q002D002B008100102Q002C0081002D00102Q002C0082002A0030A7002C00B600280012D5002D00483Q00202Q002D002D008300202Q002D002D00B500102Q002C0083002D00302Q002C007700A100122Q002D00863Q00202Q002D002D0087000618012E000B000100042Q000E012Q00044Q000E012Q002B4Q000E012Q002A4Q000E012Q002C4Q00D9002D0002000100128C002D00613Q0020A3002D002D006200122Q002E00786Q002F00246Q002D002F000200122Q002E00713Q00202Q002E002E007900122Q002F00B73Q00122Q003000B86Q002E0030000200102Q002D0067002E001252002E00713Q00202Q002E002E006200122Q002F008B3Q00122Q003000B93Q00122Q003100283Q00122Q003200BA6Q002E0032000200102Q002D0029002E00302Q002D0072002800122Q002E00BB3Q002034002F000800642Q00B9002E002E002F0010C1002D0073002E00121E012E00483Q00202Q002E002E007F00202Q002E002E00BC00102Q002D007F002E00122Q002E00133Q002060002E002E001400122Q002F00BD3Q00122Q003000BD3Q00122Q003100BD6Q002E00310002001038002D0082002E00302Q002D008100BE00122Q002E00483Q00202Q002E002E008300202Q002E002E00A500102Q002D0083002E00302Q002D007700A1000618012E000C000100012Q000E012Q00244Q005B002F002E3Q00122Q003000BF3Q00122Q0031009E6Q002F003100014Q002F002E3Q00122Q003000C03Q00122Q003100C16Q002F003100014Q002F002E3Q00122Q003000C23Q0012F6003100C34Q0076002F003100014Q002F002E3Q00122Q003000C43Q00122Q003100C56Q002F003100014Q002F002E3Q00122Q003000C63Q00122Q003100C73Q00122Q0032006F3Q00122Q003300133Q0020340033003300140012F5003400163Q00122Q003500C83Q00122Q003600C86Q003300366Q002F3Q00014Q002F3Q00024Q00305Q00102Q002F00C900304Q00305Q00102Q002F00CA003000128C003000133Q00206000300030001400122Q0031001E3Q00122Q003200193Q00122Q003300166Q0030003300020006180131000D000100032Q000E012Q00244Q000E012Q002F4Q000E012Q00043Q0006180132000E000100012Q000E012Q00043Q0006180133000F000100072Q000E012Q00244Q000E012Q002F4Q000E012Q00324Q000E012Q000A4Q000E012Q00034Q000E012Q00014Q000E012Q00043Q00061801340010000100012Q000E012Q00243Q00127D003500613Q00202Q00350035006200122Q003600786Q003700246Q00350037000200122Q003600713Q00202Q00360036007900122Q003700CB3Q00122Q003800B86Q00360038000200102Q00350067003600122Q003600713Q00202Q00360036006200122Q0037008B3Q00122Q003800CC3Q00122Q003900283Q00122Q003A00CD6Q0036003A000200102Q00350029003600302Q00350072002800302Q0035007300CE00122Q003600483Q00202Q00360036007F00202Q0036003600A400102Q0035007F003600122Q003600133Q00202Q00360036001400122Q003700CF3Q00122Q003800D03Q00122Q003900D16Q00360039000200102Q00350082003600302Q0035008100BE00302Q003500B6002800302Q0035007700D200122Q003600613Q00202Q00360036006200122Q003700706Q003800246Q00360038000200122Q003700713Q00202Q00370037007900122Q003800C83Q00122Q003900A86Q00370039000200102Q00360067003700122Q003700713Q00202Q00370037006200122Q003800283Q00122Q003900D33Q00122Q003A00283Q00122Q003B00AA6Q0037003B000200102Q00360029003700122Q003700133Q00202Q00370037001400122Q003800CF3Q00122Q003900D03Q00122Q003A00D16Q0037003A000200102Q0036008E003700302Q0036007300D400122Q003700133Q00202Q00370037006200122Q003800283Q00122Q003900283Q00122Q003A00286Q0037003A000200102Q00360082003700122Q003700483Q00202Q00370037007F00202Q0037003700A400102Q0036007F003700302Q0036008100BE00302Q00360077001900122Q003700613Q00202Q00370037006200122Q003800926Q003900366Q003700390002001282003800943Q00202Q00380038006200122Q003900153Q00122Q003A00A26Q0038003A000200102Q00370093003800202Q0037003600AD00202Q00370037005E00061801390011000100032Q000E012Q00164Q000E012Q00044Q000E012Q00354Q00A80037003900012Q00ED00375Q00061801380012000100042Q000E012Q00244Q000E012Q00374Q000E012Q00034Q000E012Q000D3Q00121F013900613Q00202Q00390039006200122Q003A009D6Q003B00166Q0039003B000200122Q003A00713Q00202Q003A003A007900122Q003B001E3Q00122Q003C001E6Q003A003C000200102Q00390067003A00122Q003A00133Q00202Q003A003A001400122Q003B006F3Q00122Q003C006F3Q00122Q003D006F6Q003A003D000200102Q0039008E003A00302Q0039007200D500302Q003900A0001500122Q003A00613Q00202Q003A003A006200122Q003B00926Q003C00396Q003A003C000200122Q003B00943Q00202Q003B003B006200122Q003C00283Q00122Q003D00156Q003B003D000200102Q003A0093003B00122Q003A00613Q00202Q003A003A006200122Q003B009D6Q003C00396Q003A003C000200122Q003B00713Q00202Q003B003B007900122Q003C00A23Q00122Q003D00A26Q003B003D000200102Q003A0067003B00122Q003B00713Q00202Q003B003B006200122Q003C008B3Q00122Q003D00153Q00122Q003E008B3Q00122Q003F00156Q003B003F000200102Q003A0029003B00122Q003B00D73Q00202Q003B003B006200122Q003C008B3Q00122Q003D008B6Q003B003D000200102Q003A00D6003B00302Q003A0077006F00302Q003A00A0001500122Q003B00613Q00202Q003B003B006200122Q003C00926Q003D003A6Q003B003D000200122Q003C00943Q00202Q003C003C006200122Q003D00283Q00122Q003E00156Q003C003E000200102Q003B0093003C00122Q003B00613Q00202Q003B003B006200122Q003C009D6Q003D00166Q003B003D000200122Q003C00713Q00202Q003C003C007900122Q003D00AE3Q00122Q003E00D86Q003C003E000200102Q003B0067003C0030A7003B007200280030A7003B00A00015000618013C0013000100012Q000E012Q003B4Q0049003D3Q000500122Q003E00483Q00202Q003E003E004900202Q003E003E00D94Q003F003C3Q00122Q004000D93Q00122Q004100713Q00202Q00410041007900122Q004200DA3Q00122Q004300DA6Q00410043000200122Q004200713Q00202Q00420042007900122Q004300DB3Q00122Q0044007D6Q004200446Q003F3Q00024Q003D003E003F00122Q003E00483Q00202Q003E003E004900202Q003E003E00DC4Q003F003C3Q00122Q004000DC3Q00122Q004100713Q00202Q00410041007900122Q004200DA3Q00122Q004300DA6Q00410043000200122Q004200713Q00202Q00420042007900122Q004300DD3Q00122Q0044009C6Q004200446Q003F3Q00024Q003D003E003F00122Q003E00483Q00202Q003E003E004900202Q003E003E00DE4Q003F003C3Q00122Q004000DE3Q00122Q004100713Q00202Q00410041007900122Q004200DA3Q00122Q004300DA6Q00410043000200122Q004200713Q00202Q00420042007900122Q004300DB3Q00122Q0044009C6Q004200446Q003F3Q00024Q003D003E003F00122Q003E00483Q00202Q003E003E004900202Q003E003E00DF4Q003F003C3Q00122Q004000DF3Q00122Q004100713Q00202Q00410041007900122Q004200DA3Q00122Q004300DA6Q00410043000200122Q004200713Q00202Q00420042007900122Q004300CF3Q00122Q0044009C6Q004200446Q003F3Q00024Q003D003E003F00122Q003E00483Q00202Q003E003E004900202Q003E003E00E04Q003F003C3Q00122Q004000E13Q00122Q004100713Q00202Q00410041007900122Q004200E23Q00122Q004300A16Q00410043000200122Q004200713Q00201700420042007900122Q004300DD3Q00122Q004400E36Q004200446Q003F3Q00024Q003D003E003F00122Q003E00483Q00202Q003E003E004900202Q003E003E00E04Q003E003D003E002034003E003E00780030A7003E008100E4000618013E0014000100042Q000E012Q000D4Q000E012Q00394Q000E012Q003B4Q000E012Q003D4Q0079003F5Q00122Q0040005A3Q00202Q00400040005B4Q0041000A3Q00202Q0042000300E500202Q00420042005E00061801440015000100022Q000E012Q003D4Q000E012Q003F4Q00A2004200446Q00403Q000100122Q0040005A3Q00202Q00400040005B4Q0041000A3Q00202Q0042000300E600202Q00420042005E00061801440016000100022Q000E012Q003D4Q000E012Q003F4Q0010004200446Q00403Q00014Q004000313Q00122Q004100E73Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600E84Q002D00420046000200202Q0043000D002100122Q004400226Q0040004400014Q004000313Q00122Q004100E93Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q0012F6004500153Q001226004600D26Q00420046000200202Q0043000D002100122Q004400256Q0040004400014Q004000343Q00122Q004100EA3Q00122Q004200713Q00202Q00420042006200122Q004300153Q0012F60044009E3Q0012E2004500153Q00122Q004600EB6Q0042004600024Q004300063Q00122Q004400123Q00122Q004500183Q00122Q0046001A3Q00122Q0047001C3Q00122Q0048001D3Q00122Q0049001F4Q006C00430006000100061801440017000100022Q000E012Q000D4Q000E012Q000C4Q00930040004400014Q004000343Q00122Q004100EC3Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600ED6Q0042004600022Q001C014300043Q00128F0044002A3Q00122Q004500EE3Q00122Q004600EF3Q00122Q004700F06Q00430004000100061801440018000100022Q000E012Q000D4Q000E012Q003E4Q00930040004400014Q004000333Q00122Q004100F13Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600AE6Q0042004600020012F60043008B3Q0012F6004400F23Q0012F6004500283Q00061801460019000100022Q000E012Q000D4Q000E012Q003E4Q006D0040004600014Q004000313Q00122Q004100F33Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600F46Q00420046000200202Q0043000D003000122Q004400226Q0040004400014Q004000313Q00122Q004100F53Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600AF6Q00420046000200202Q0043000D003000122Q004400256Q0040004400014Q004000313Q00122Q004100F63Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600F76Q00420046000200202Q0043000D003000122Q004400316Q0040004400014Q004000313Q00122Q004100F83Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600F96Q00420046000200202Q0043000D003000122Q004400366Q0040004400014Q004000313Q00122Q004100FA3Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600166Q00420046000200202Q0043000D003000122Q004400326Q0040004400014Q004000313Q00122Q004100FB3Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q004600FC6Q00420046000200202Q0043000D003000122Q004400336Q0040004400014Q004000313Q00122Q004100FD3Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q001226004600FE6Q00420046000200202Q0043000D003000122Q004400356Q0040004400014Q004000343Q00122Q004100FF3Q00122Q004200713Q00202Q00420042006200122Q004300153Q0012F60044009E3Q0012E2004500153Q00122Q00462Q00015Q0042004600024Q004300073Q00122Q004400123Q00122Q004500183Q00122Q0046001A3Q00122Q0047001C3Q00122Q0048001D3Q00122Q0049001F3Q0012F6004A00204Q006C0043000700010006180144001A000100022Q000E012Q000D4Q000E012Q000C3Q0012CB004500186Q0040004500014Q004000343Q00122Q0041002Q012Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q0044009E3Q00122Q004500153Q00122Q00460002013Q00710042004600022Q0013004300073Q00122Q004400123Q00122Q004500183Q00122Q0046001A3Q00122Q0047001C3Q00122Q0048001D3Q00122Q0049001F3Q00122Q004A00206Q0043000700010006180144001B000100022Q000E012Q000D4Q000E012Q000C3Q0012CB0045001F6Q0040004500014Q004000313Q00122Q00410003012Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q004400C13Q00122Q004500153Q00122Q004600E84Q002D00420046000200202Q0043000D003700122Q004400226Q0040004400014Q004000313Q00122Q00410004012Q00122Q004200713Q00202Q00420042006200122Q004300153Q00122Q004400C13Q0012F6004500153Q001226004600D26Q00420046000200202Q0043000D003700122Q004400256Q0040004400014Q004000313Q00122Q00410005012Q00122Q004200713Q00202Q00420042006200122Q004300153Q0012F6004400C13Q0012F6004500153Q001226004600C86Q00420046000200202Q0043000D003700122Q004400316Q0040004400014Q004000343Q00122Q00410006012Q00122Q004200713Q00202Q00420042006200122Q004300153Q0012F6004400C13Q0012E2004500153Q00122Q004600176Q0042004600024Q004300073Q00122Q004400123Q00122Q004500183Q00122Q0046001A3Q00122Q0047001C3Q00122Q0048001D3Q00122Q0049001F3Q0012F6004A00204Q006C0043000700010006180144001C000100022Q000E012Q000D4Q000E012Q000C4Q006300400044000100122Q004000C36Q004100333Q00122Q00420007012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q004700E84Q00710043004700020012F60044007B3Q0012F6004500B03Q0012F6004600533Q0006180147001D000100012Q000E012Q000D4Q003D0041004700014Q004100313Q00122Q0042003F3Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q004700C86Q0043004700020020340044000D003E0012D30045003F6Q0041004500014Q004100333Q00122Q004200403Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q00470008013Q00710043004700020012F600440009012Q0012F6004500F23Q0012F6004600153Q0006180147001E000100012Q000E012Q000D4Q003D0041004700014Q004100333Q00122Q004200413Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q0047000A015Q0043004700020012F600440009012Q0012F6004500F23Q0012F6004600153Q0006180147001F000100012Q000E012Q000D4Q003D0041004700014Q004100313Q00122Q0042000B012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q004700F46Q0043004700020020340044000D00380012F6004500393Q00061801460020000100012Q000E012Q001A4Q003D0041004600014Q004100313Q00122Q0042000C012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q004700AF6Q0043004700020020340044000D00380012D30045003B6Q0041004500014Q004100343Q00122Q0042000D012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q0047000E013Q00710043004700022Q0013004400073Q00122Q004500123Q00122Q004600183Q00122Q0047001A3Q00122Q0048001C3Q00122Q0049001D3Q00122Q004A001F3Q00122Q004B00206Q00440007000100061801450021000100022Q000E012Q000D4Q000E012Q000C3Q0012D30046001F6Q0041004600014Q004100333Q00122Q0042000F012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q00470010013Q00710043004700020012F60044006F3Q0012F60045009A3Q0012F60046003D3Q00061801470022000100022Q000E012Q000D4Q000E012Q001A4Q003D0041004700014Q004100313Q00122Q00420011012Q00122Q004300713Q00202Q00430043006200122Q004400156Q004500403Q00122Q004600153Q00122Q00470012015Q0043004700020020340044000D003E0012C6004500446Q004600226Q00410046000100122Q004100C56Q004200333Q00122Q00430013012Q00122Q004400713Q00202Q00440044006200122Q004500156Q004600413Q0012F6004700153Q001275004800E86Q00440048000200122Q004500153Q00122Q004600173Q00202Q0047000D004E00202Q00470047004F00061801480023000100022Q000E012Q000D4Q000E012Q00114Q003D0042004800014Q004200333Q00122Q00430014012Q00122Q004400713Q00202Q00440044006200122Q004500156Q004600413Q00122Q004700153Q00122Q004800C86Q0044004800020012F600450015012Q0012F600460016012Q0020340047000D004E00203400470047005000061801480024000100022Q000E012Q000D4Q000E012Q00114Q003D0042004800014Q004200313Q00122Q00430017012Q00122Q004400713Q00202Q00440044006200122Q004500156Q004600413Q00122Q004700153Q00122Q00480018015Q0044004800020020340045000D004E0012F6004600513Q00061801470025000100012Q000E012Q00114Q002000420047000100122Q004200C76Q004300313Q00122Q00440019012Q00122Q004500713Q00202Q00450045006200122Q004600156Q004700423Q00122Q004800153Q00122Q004900E86Q00450049000200202Q0046000D003E00122Q004700456Q004800483Q00122Q004900133Q00202Q00490049001400122Q004A00163Q00122Q004B00C83Q00122Q004C00C86Q0049004C6Q00433Q00014Q004300313Q00122Q0044001A012Q00122Q004500713Q00202Q00450045006200122Q004600156Q004700423Q00122Q004800153Q00122Q0049001B015Q00450049000200202Q0046000D003E00122Q004700466Q004800483Q00122Q004900133Q00202Q00490049001400122Q004A00163Q00122Q004B00C83Q00122Q004C00C86Q0049004C6Q00433Q00014Q004300383Q00122Q004400713Q00202Q00440044006200122Q004500153Q00122Q0046001C015Q00460042004600122Q004700153Q00122Q0048001D015Q00440048000200202Q0045000D003E00122Q004600476Q0043004600014Q004300333Q00122Q0044001E012Q00122Q004500713Q00202Q00450045006200122Q004600156Q004700423Q00122Q004800153Q00122Q0049001F015Q00450049000200122Q004600193Q00122Q00470020012Q00122Q004800193Q00061801490026000100012Q000E012Q000D3Q0012FA004A00133Q00202Q004A004A001400122Q004B00163Q00122Q004C00C83Q00122Q004D00C86Q004A004D6Q00433Q00014Q00438Q004400313Q00122Q00450021012Q00128C004600713Q00207C00460046006200122Q004700156Q004800423Q00122Q004900153Q00122Q004A001C015Q0046004A000200202Q0047000D003E00122Q0048004C3Q00061801490027000100012Q000E012Q00433Q001266004A00133Q00202Q004A004A001400122Q004B00163Q00122Q004C00C83Q00122Q004D00C86Q004A004D6Q00443Q00014Q004400333Q00122Q00450022012Q00122Q004600713Q00203400460046006200128E004700156Q004800423Q00122Q004900153Q00122Q004A001B6Q0046004A000200122Q004700153Q00122Q004800173Q00122Q0049003D3Q000618014A0028000100012Q000E012Q000D3Q001299004B00133Q00202Q004B004B001400122Q004C00163Q00122Q004D00C83Q00122Q004E00C86Q004B004E6Q00443Q000100122Q004400613Q00202Q00440044006200122Q004500706Q004600246Q00440046000200122Q00450023012Q00102Q00440064004500122Q004500713Q00202Q00450045006200122Q004600153Q00122Q00470024012Q00122Q004800153Q00122Q00490025015Q00450049000200102Q00440067004500122Q004500713Q00202Q00450045006200122Q004600153Q00122Q004700A26Q00470042004700122Q004800153Q00122Q0049007D6Q00450049000200102Q00440029004500122Q004500133Q00202Q00450045001400122Q0046003D3Q00122Q0047003D3Q00122Q004800986Q00450048000200102Q0044008E004500122Q00450026012Q00102Q00440072004500122Q004500153Q00102Q004400A0004500302Q00440073007400122Q00450027015Q00468Q00440045004600122Q00450028012Q00102Q00440077004500122Q004500613Q00202Q00450045006200122Q004600926Q004700446Q00450047000200122Q004600943Q00202Q00460046006200122Q004700153Q00122Q004800DD6Q00460048000200102Q00450093004600122Q004600613Q00202Q00460046006200122Q004700786Q004800446Q00460048000200122Q004700713Q00202Q00470047006200122Q004800283Q00122Q00490029012Q00122Q004A00153Q00122Q004B00B06Q0047004B000200102Q00460067004700122Q004700713Q00202Q00470047006200122Q004800153Q00122Q004900E43Q00122Q004A00153Q00122Q004B0028015Q0047004B000200102Q0046002900470012F6004700283Q00104000460072004700122Q0047002A012Q00102Q00460073004700122Q004700133Q00202Q00470047001400122Q004800163Q00122Q004900C83Q00122Q004A00C86Q0047004A000200102Q00460082004700122Q004700483Q00202Q00470047007F00202Q0047004700A400102Q0046007F004700122Q004700BE3Q00102Q00460081004700122Q0047002B015Q004800016Q00460047004800122Q0047002C012Q00102Q00460077004700122Q004700613Q00202Q00470047006200122Q004800706Q004900446Q00470049000200122Q004800713Q00202Q00480048007900122Q004900BD3Q00122Q004A007B6Q0048004A000200102Q00470067004800122Q004800713Q00202Q00480048006200122Q0049008B3Q00122Q004A002D012Q00122Q004B00153Q00122Q004C00AB6Q0048004C000200102Q00470029004800122Q004800133Q00202Q00480048001400122Q004900E83Q00122Q004A00E83Q00122Q004B002E015Q0048004B000200102Q0047008E004800122Q0048002F012Q00102Q00470073004800122Q004800133Q00202Q00480048001400122Q00490030012Q00122Q004A0030012Q00122Q004B0030015Q0048004B000200102Q00470082004800122Q004800483Q00202Q00480048007F00202Q0048004800A400102Q0047007F004800122Q004800BE3Q00102Q00470081004800122Q00480031012Q00102Q00470077004800122Q004800613Q00202Q00480048006200122Q004900926Q004A00476Q0048004A000200122Q004900943Q00202Q00490049006200122Q004A00153Q00122Q004B00A26Q0049004B000200102Q00480093004900202Q0049004700AD00202Q00490049005E000618014B0029000100042Q000E012Q00044Q000E012Q00444Q000E012Q00464Q000E012Q00474Q00720049004B00014Q00495Q00122Q004A00713Q00202Q004A004A006200122Q004B008B3Q00122Q004C008C3Q00122Q004D008B3Q00122Q004E0032015Q004A004E0002000618014B002A000100072Q000E012Q00494Q000E012Q00194Q000E012Q00034Q000E012Q00044Q000E012Q00244Q000E012Q004A4Q000E012Q00153Q0012B1004C005A3Q00202Q004C004C005B4Q004D000A3Q00202Q004E000300E500202Q004E004E005E0006180150002B000100032Q000E012Q000D4Q000E012Q00374Q000E012Q004B4Q00A6004E00506Q004C3Q00014Q004C004E3Q00202Q004F002400E500202Q004F004F005E0006180151002C000100042Q000E012Q004C4Q000E012Q004D4Q000E012Q004E4Q000E012Q00244Q00BF004F0051000100122Q004F005A3Q00202Q004F004F005B4Q0050000A3Q00202Q00510001008500202Q00510051005E0006180153002D000100052Q000E012Q004C4Q000E012Q00034Q000E012Q004D4Q000E012Q00244Q000E012Q004E4Q00F9005100536Q004F3Q000100122Q004F005A3Q00202Q004F004F005B4Q0050000A3Q00122Q00510033015Q00513Q005100202Q00510051005E0006180153002E000100012Q000E012Q00214Q00A2005100536Q004F3Q000100122Q004F005A3Q00202Q004F004F005B4Q0050000A3Q00202Q00510001008500202Q00510051005E0006180153002F000100182Q000E012Q000D4Q000E012Q00304Q000E012Q001A4Q000E012Q00494Q000E012Q00034Q000E012Q002F4Q000E012Q003B4Q000E012Q003A4Q000E012Q003D4Q000E012Q003F4Q000E012Q00394Q000E012Q00084Q000E012Q001C4Q000E012Q00214Q000E012Q00054Q000E012Q00144Q000E012Q00434Q000E012Q00064Q000E017Q000E012Q001F4Q000E012Q001D4Q000E012Q001E4Q000E012Q00164Q000E012Q00204Q00A2005100536Q004F3Q000100122Q004F005A3Q00202Q004F004F005B4Q0050000A3Q00202Q0051000300E500202Q00510051005E00061801530030000100022Q000E012Q000D4Q000E012Q00084Q00F9005100536Q004F3Q000100122Q004F005A3Q00202Q004F004F005B4Q0050000A3Q00122Q00510034015Q00510003005100202Q00510051005E00061801530031000100022Q000E012Q000D4Q000E012Q00084Q009F005100536Q004F3Q00014Q004F003E6Q004F000100014Q004F003E6Q004F000100014Q004F00116Q004F000100016Q00013Q00323Q001F3Q002Q033Q0049734103053Q00536F756E6403063Q00566F6C756D6503183Q0047657450726F70657274794368616E6765645369676E616C03073Q00436F2Q6E65637403053Q007461626C6503063Q00696E73657274030D3Q00506C61796261636B53702Q6564030E3Q0046696E6446697273744368696C64030A3Q0053544B5F52657665726203053Q00417564696F03063Q0052657665726203083Q00496E7374616E63652Q033Q006E657703113Q00526576657262536F756E64452Q6665637403043Q004E616D6503093Q00446563617954696D65026Q00044003073Q0044656E73697479026Q33EB3F03093Q0044692Q667573696F6E02CD5QCCEC3F03083Q004472794C6576656C026Q0008C003083Q005765744C6576656C026Q00084003073Q00456E61626C65642Q0103063Q00506172656E74010003053Q007063612Q6C01583Q0020102Q013Q00010012F6000300024Q00710001000300020006510001000600010001000413012Q000600012Q00F73Q00014Q005500016Q002F000100013Q0006510001001D00010001000413012Q001D00012Q005500015Q00207A00023Q00034Q00013Q00024Q000100013Q00202Q00023Q000400122Q000400036Q00020004000200202Q00020002000500061801043Q000100032Q00553Q00014Q00558Q000E017Q00CF0002000400024Q000100023Q00122Q000200063Q00202Q0002000200074Q000300026Q000400016Q0002000400012Q0055000100034Q002F000100013Q0006510001003400010001000413012Q003400012Q0055000100033Q00207A00023Q00084Q00013Q00024Q000100013Q00202Q00023Q000400122Q000400086Q00020004000200202Q00020002000500061801040001000100032Q00553Q00014Q00553Q00034Q000E017Q00CF0002000400024Q000100023Q00122Q000200063Q00202Q0002000200074Q000300026Q000400016Q0002000400010020102Q013Q000900121E0003000A6Q0001000300024Q000200013Q00202Q00020002000B00202Q00020002000C00062Q0002004D00013Q000413012Q004D00010006510001004B00010001000413012Q004B000100128C0002000D3Q00205300020002000E00122Q0003000F6Q00020002000200302Q00020010000A00302Q00020011001200302Q00020013001400302Q00020015001600302Q00020017001800302Q00020019001A00302Q0002001B001C00102Q0002001D3Q00044Q005000010030A70001001B001C000413012Q0050000100064E0001005000013Q000413012Q005000010030A70001001B001E00128C0002001F3Q00061801030002000100042Q000E017Q00558Q00553Q00014Q00553Q00034Q00D90002000200012Q00F73Q00013Q00033Q00063Q0003053Q00417564696F03063Q00566F6C756D65026Q00594003043Q006D6174682Q033Q00616273027B14AE47E17A843F00184Q00947Q00206Q000100206Q000200206Q00034Q000100016Q000200026Q0001000100024Q000100013Q00122Q000200043Q00202Q0002000200054Q000300023Q00202Q0003000300024Q0003000300014Q000200020002000E2Q0006001700010002000413012Q001700012Q0055000200014Q002E000300026Q000400023Q00202Q0004000400024Q0002000300044Q000200023Q00102Q0002000200012Q00F73Q00017Q00063Q0003053Q00417564696F03053Q00506974636803043Q006D6174682Q033Q00616273030D3Q00506C61796261636B53702Q6564027B14AE47E17A843F00174Q00747Q00206Q000100206Q00024Q000100016Q000200026Q0001000100024Q000100013Q00122Q000200033Q00202Q0002000200044Q000300023Q00202Q0003000300054Q0003000300014Q000200020002000E2Q0006001600010002000413012Q001600012Q0055000200014Q002E000300026Q000400023Q00202Q0004000400054Q0002000300044Q000200023Q00102Q0002000500012Q00F73Q00017Q00053Q0003063Q00566F6C756D6503053Q00417564696F026Q005940030D3Q00506C61796261636B53702Q656403053Q00506974636800144Q00369Q00000100016Q00028Q0001000100024Q000200023Q00202Q00020002000200202Q00020002000100202Q0002000200034Q00010001000200104Q000100019Q004Q000100036Q00028Q0001000100024Q000200023Q00202Q00020002000200202Q0002000200054Q00010001000200104Q000400016Q00017Q00093Q0003053Q00417564696F03063Q00566F6C756D65026Q00594003053Q007063612Q6C03093Q00776F726B737061636503063Q00697061697273030E3Q0047657444657363656E64616E74732Q033Q0049734103053Q00536F756E6400234Q00227Q00206Q000100206Q000200206Q000300122Q000100043Q00061801023Q000100012Q000E017Q00160001000200014Q000100033Q00122Q000200056Q000300016Q000400026Q00010003000100128C000200064Q000E010300014Q00C8000200020004000413012Q0020000100128C000700063Q0020100108000600074Q000800094Q00C900073Q0009000413012Q001E0001002010010C000B00080012F6000E00094Q0071000C000E000200064E000C001E00013Q000413012Q001E00012Q0055000C00034Q000E010D000B4Q00D9000C0002000100062B0007001600010002000413012Q0016000100062B0002001100010002000413012Q001100012Q00F73Q00013Q00013Q00033Q00030C3Q005573657253652Q74696E6773030C3Q0047616D6553652Q74696E6773030C3Q004D6173746572566F6C756D6500063Q0012973Q00018Q0001000200206Q00024Q00015Q00104Q000300016Q00017Q00043Q00030F3Q0044657363656E64616E74412Q64656403073Q00436F2Q6E65637403053Q007461626C6503063Q00696E73657274010B3Q00203400013Q00010020102Q010001000200061801033Q000100012Q00558Q001A00010003000200122Q000200033Q00202Q0002000200044Q000300016Q000400016Q0002000400016Q00013Q00013Q00043Q002Q033Q0049734103053Q00536F756E6403043Q007461736B03053Q006465666572010B3Q0020102Q013Q00010012F6000300024Q007100010003000200064E0001000A00013Q000413012Q000A000100128C000100033Q0020340001000100042Q005500026Q000E01036Q00A80001000300012Q00F73Q00017Q00063Q0003183Q0047657450726F70657274794368616E6765645369676E616C030B3Q004669656C644F665669657703073Q00436F2Q6E65637403053Q007461626C6503063Q00696E736572742Q033Q00464F5601163Q0006513Q000300010001000413012Q000300012Q00F73Q00014Q00B5000100013Q00201001023Q00010012F6000400024Q007100020004000200201001020002000300061801043Q000100022Q000E017Q00558Q00960002000400024Q000100023Q00122Q000200043Q00202Q0002000200054Q000300016Q000400016Q0002000400014Q00025Q00202Q00020002000600104Q000200026Q00013Q00013Q00023Q00030B3Q004669656C644F66566965772Q033Q00464F56000B4Q000D7Q00206Q00014Q000100013Q00202Q00010001000200064Q000A00010001000413012Q000A00012Q00558Q0055000100013Q0020340001000100020010C13Q000100012Q00F73Q00017Q00023Q0003093Q00776F726B7370616365030D3Q0043752Q72656E7443616D65726100054Q00B77Q00122Q000100013Q00202Q0001000100026Q000200016Q00017Q00013Q0003063Q00506172656E7400044Q00558Q0055000100013Q0010C13Q000100012Q00F73Q00017Q00033Q0003043Q006D61746803053Q00726F756E64026Q00F03F01063Q0012A0000100013Q00202Q00010001000200102Q000200036Q0001000200024Q00019Q0000017Q00073Q0003043Q007461736B03043Q0077616974026Q00E03F03063Q00506172656E7403043Q005465787403053Q004650533A2003083Q00746F737472696E6700173Q00128C3Q00013Q0020345Q00020012F6000100034Q000A3Q0002000200064E3Q001600013Q000413012Q001600012Q00557Q00064E3Q001600013Q000413012Q001600012Q00557Q0020345Q00040006513Q000E00010001000413012Q000E0001000413012Q001600012Q00553Q00013Q0012AD000100063Q00122Q000200076Q000300026Q0002000200024Q00010001000200104Q0005000100046Q00012Q00F73Q00017Q00013Q0003053Q007063612Q6C010A3Q00128C000100013Q00061801023Q000100062Q00558Q000E017Q00553Q00014Q00553Q00024Q00553Q00034Q00553Q00044Q00D90001000200012Q00F73Q00013Q00013Q00053Q0003073Q0044657374726F790003073Q0056697369626C65010003063Q0052656D6F7665004A4Q00558Q0055000100014Q002F5Q000100064E3Q000D00013Q000413012Q000D00012Q00558Q00EB000100019Q00000100206Q00016Q000200019Q004Q000100013Q00204Q000100022Q00553Q00024Q0055000100014Q002F5Q000100064E3Q001A00013Q000413012Q001A00012Q00553Q00024Q00EB000100019Q00000100206Q00016Q000200016Q00026Q000100013Q00204Q000100022Q00553Q00034Q0055000100014Q002F5Q000100064E3Q002700013Q000413012Q002700012Q00553Q00034Q00EB000100019Q00000100206Q00016Q000200016Q00036Q000100013Q00204Q000100022Q00553Q00044Q0055000100014Q002F5Q000100064E3Q003800013Q000413012Q003800012Q00553Q00044Q006A000100019Q00000100304Q000300046Q00046Q000100019Q00000100206Q00056Q000200016Q00046Q000100013Q00204Q000100022Q00553Q00054Q0055000100014Q002F5Q000100064E3Q004900013Q000413012Q004900012Q00553Q00054Q006A000100019Q00000100304Q000300046Q00056Q000100019Q00000100206Q00056Q000200016Q00056Q000100013Q00204Q000100022Q00F73Q00017Q00023Q0003043Q007461736B03053Q00737061776E01083Q00128C000100013Q00203400010001000200061801023Q000100032Q00558Q000E017Q00553Q00014Q00D90001000200012Q00F73Q00013Q00013Q000C3Q00030D3Q00476C6F62616C536861646F777303093Q00776F726B7370616365030E3Q0047657444657363656E64616E747303063Q0069706169727303053Q00576F726C6403083Q00465053422Q6F73742Q0103053Q007063612Q6C025Q00C06240028Q0003043Q007461736B03043Q007761697400234Q00339Q00000100016Q000100013Q00104Q0001000100124Q00023Q00206Q00036Q0002000200122Q000100046Q00028Q00010002000300044Q002000012Q0055000600023Q0020340006000600050020340006000600060006510006001400010001000413012Q001400012Q0055000600013Q00269C0006001400010007000413012Q00140001000413012Q0022000100128C000600083Q00061801073Q000100022Q000E012Q00054Q00553Q00014Q00D900060002000100208A00060004000900269C0006001F0001000A000413012Q001F000100128C0006000B3Q00203400060006000C2Q00910006000100012Q00CD00045Q00062B0001000B00010002000413012Q000B00012Q00F73Q00013Q00013Q00143Q002Q033Q0049734103083Q00426173655061727403083Q004D6573685061727403083Q004D6174657269616C03043Q00456E756D030D3Q00536D2Q6F7468506C617374696303073Q00506C6173746963030A3Q0043617374536861646F77030B3Q005265666C656374616E6365028Q0003073Q005465787475726503053Q00446563616C030C3Q005472616E73706172656E6379026Q00F03F030F3Q005061727469636C65456D692Q74657203053Q00547261696C03053Q00536D6F6B6503083Q00537061726B6C657303043Q004669726503073Q00456E61626C6564005C4Q00DC7Q00206Q000100122Q000200028Q0002000200064Q000C00010001000413012Q000C00012Q00557Q002010014Q00010012F6000200034Q00713Q0002000200064E3Q002300013Q000413012Q002300012Q00558Q0055000100013Q00064E0001001500013Q000413012Q0015000100128C000100053Q0020340001000100040020340001000100060006510001001800010001000413012Q0018000100128C000100053Q0020340001000100040020340001000100070010C13Q000400012Q00FC9Q00000100016Q000100013Q00104Q000800016Q00013Q00064Q005B00013Q000413012Q005B00012Q00557Q0030A73Q0009000A000413012Q005B00012Q00557Q002010014Q00010012F60002000B4Q00713Q000200020006513Q002F00010001000413012Q002F00012Q00557Q002010014Q00010012F60002000C4Q00713Q0002000200064E3Q003900013Q000413012Q003900012Q00558Q0055000100013Q00064E0001003600013Q000413012Q003600010012F60001000E3Q0006510001003700010001000413012Q003700010012F60001000A3Q0010C13Q000D0001000413012Q005B00012Q00557Q002010014Q00010012F60002000F4Q00713Q000200020006513Q005700010001000413012Q005700012Q00557Q002010014Q00010012F6000200104Q00713Q000200020006513Q005700010001000413012Q005700012Q00557Q002010014Q00010012F6000200114Q00713Q000200020006513Q005700010001000413012Q005700012Q00557Q002010014Q00010012F6000200124Q00713Q000200020006513Q005700010001000413012Q005700012Q00557Q002010014Q00010012F6000200134Q00713Q0002000200064E3Q005B00013Q000413012Q005B00012Q00558Q0055000100014Q000D2Q0100013Q0010C13Q001400012Q00F73Q00017Q001D3Q0003063Q00697061697273030A3Q00446973636F2Q6E65637403063Q00466F67456E64025Q0088C34003073Q00416D6269656E7403063Q00436F6C6F72332Q033Q006E6577028Q00030A3Q004272696768746E652Q73026Q00F03F03073Q0044657374726F7903093Q00776F726B7370616365030D3Q0043752Q72656E7443616D657261030B3Q004669656C644F6656696577025Q00805140030A3Q00476574506C617965727303053Q00576F726C6403083Q00465053422Q6F73740100030E3Q0047657444657363656E64616E74732Q033Q0049734103053Q00536F756E64030E3Q0046696E6446697273744368696C64030A3Q0053544B5F52657665726203053Q00706169727303063Q00506172656E7403053Q007063612Q6C03053Q007072696E74031E3Q005354414C4B45523A20506F776572204F2Q662053752Q63652Q7366756C2E008E3Q00128C3Q00014Q005500016Q00C83Q00020002000413012Q0008000100064E0004000800013Q000413012Q000800010020100105000400022Q00D900050002000100062B3Q000400010002000413012Q0004000100128C3Q00014Q0055000100014Q00C83Q00020002000413012Q0012000100064E0004001200013Q000413012Q001200010020100105000400022Q00D900050002000100062B3Q000E00010002000413012Q000E00012Q00553Q00023Q0030023Q000300046Q00023Q00122Q000100063Q00202Q00010001000700122Q000200083Q00122Q000300083Q00122Q000400086Q00010004000200104Q000500016Q00023Q00304Q0009000A6Q00033Q00064Q002600013Q000413012Q002600012Q00553Q00033Q002010014Q000B2Q00D93Q000200012Q00553Q00043Q00064E3Q002C00013Q000413012Q002C00012Q00553Q00043Q002010014Q000B2Q00D93Q0002000100128C3Q000C3Q0020345Q000D00064E3Q003100013Q000413012Q003100010030A73Q000E000F00128C000100014Q002Q010200053Q00202Q0002000200104Q000200036Q00013Q000300044Q003A00012Q0055000600064Q000E010700054Q00D900060002000100062B0001003700010002000413012Q003700012Q0055000100073Q0020EA00010001001100302Q0001001200134Q000100086Q00028Q0001000200014Q000100033Q00122Q0002000C6Q000300096Q000400056Q00010003000100128C000200014Q000E010300014Q00C8000200020004000413012Q005E000100128C000700013Q0020100108000600144Q000800094Q00C900073Q0009000413012Q005C0001002010010C000B00150012F6000E00164Q0071000C000E000200064E000C005C00013Q000413012Q005C0001002010010C000B00170012F6000E00184Q0071000C000E000200064E000C005C00013Q000413012Q005C0001002010010D000C000B2Q00D9000D0002000100062B0007005000010002000413012Q0050000100062B0002004B00010002000413012Q004B000100128C000200194Q00550003000A4Q00C8000200020004000413012Q006F000100064E0005006E00013Q000413012Q006E000100203400070005001A00064E0007006E00013Q000413012Q006E000100128C0007001B3Q00061801083Q000100022Q000E012Q00054Q000E012Q00064Q00D90007000200012Q00CD00055Q00062B0002006400010002000413012Q0064000100128C000200194Q00550003000B4Q00C8000200020004000413012Q0080000100064E0005007F00013Q000413012Q007F000100203400070005001A00064E0007007F00013Q000413012Q007F000100128C0007001B3Q00061801080001000100022Q000E012Q00054Q000E012Q00064Q00D90007000200012Q00CD00055Q00062B0002007500010002000413012Q0075000100128C0002001B3Q00061801030002000100022Q00553Q000C4Q00553Q000D4Q00050002000200014Q0002000E3Q00202Q00020002000B4Q00020002000100122Q0002001C3Q00122Q0003001D6Q0002000200016Q00013Q00033Q00013Q0003063Q00566F6C756D6500044Q00558Q0055000100013Q0010C13Q000100012Q00F73Q00017Q00013Q00030D3Q00506C61796261636B53702Q656400044Q00558Q0055000100013Q0010C13Q000100012Q00F73Q00017Q00063Q0003093Q0043686172616374657203153Q0046696E6446697273744368696C644F66436C612Q7303083Q0048756D616E6F696403123Q0043686172616374657257616C6B53702Q6564026Q00304003093Q0057616C6B53702Q656400174Q00557Q0020345Q000100064E3Q001600013Q000413012Q001600012Q00557Q0020195Q000100206Q000200122Q000200038Q0002000200064Q001600013Q000413012Q001600012Q00553Q00013Q0020345Q00040006513Q001000010001000413012Q001000010012F63Q00054Q005500015Q0020E600010001000100202Q00010001000200122Q000300036Q00010003000200102Q000100064Q00F73Q00017Q00183Q0003093Q0054772Q656E496E666F2Q033Q006E6577029A5Q99014003043Q00456E756D030B3Q00456173696E675374796C6503043Q0053696E65030F3Q00456173696E67446972656374696F6E03053Q00496E4F7574026Q00F0BF03063Q00437265617465030A3Q0054657874436F6C6F723303103Q00546578745472616E73706172656E637902CD5QCCDC3F03043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00407040026Q003B4003083Q00506F736974696F6E028Q00026Q002A40026Q00F03F025Q008041C003043Q00506C617900363Q00125E3Q00013Q00206Q000200122Q000100033Q00122Q000200043Q00202Q00020002000500202Q00020002000600122Q000300043Q00202Q00030003000700202Q00030003000800122Q000400096Q000500018Q000500024Q00015Q00202Q00010001000A4Q000300016Q00048Q00053Q00014Q000600023Q00102Q0005000B00064Q0001000500024Q00025Q00202Q00020002000A4Q000400036Q00058Q00063Q000100302Q0006000C000D4Q0002000600024Q00035Q00202Q00030003000A4Q000500036Q00068Q00073Q000200122Q0008000F3Q00202Q00080008001000122Q000900113Q00122Q000A00126Q0008000A000200102Q0007000E000800122Q0008000F3Q00202Q00080008000200122Q000900143Q00122Q000A00153Q00122Q000B00163Q00122Q000C00176Q0008000C000200102Q0007001300084Q00030007000200202Q0004000100184Q00040002000100202Q0004000200184Q00040002000100202Q0004000300184Q0004000200016Q00017Q001A3Q0003083Q00496E7374616E63652Q033Q006E657703093Q00546578744C6162656C03043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00C06740026Q00344003083Q00506F736974696F6E026Q00244003163Q004261636B67726F756E645472616E73706172656E6379026Q00F03F03043Q005465787403053Q00752Q706572030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00C0624003043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65030E3Q005465787458416C69676E6D656E7403043Q004C65667403063Q005A496E646578026Q002640042C3Q001224000400013Q00202Q00040004000200122Q000500036Q00068Q00040006000200122Q000500053Q00202Q00050005000600122Q000600073Q00122Q000700086Q00050007000200102Q00040004000500122Q000500053Q00202Q0005000500064Q000600013Q00062Q0007001100010002000413012Q001100010012F60007000A4Q00710005000700020010DA00040009000500302Q0004000B000C00202Q00053Q000E4Q00050002000200102Q0004000D000500062Q0005001F00010003000413012Q001F000100128C000500103Q00206000050005001100122Q000600123Q00122Q000700123Q00122Q000800126Q0005000800020010C10004000F0005001298000500143Q00202Q00050005001300202Q00050005001500102Q00040013000500302Q00040016000A00122Q000500143Q00202Q00050005001700202Q00050005001800102Q00040017000500302Q00040019001A4Q000400028Q00017Q00373Q0003083Q00496E7374616E63652Q033Q006E6577030A3Q005465787442752Q746F6E03043Q0053697A6503053Q005544696D32028Q00025Q00C06740026Q00364003083Q00506F736974696F6E03163Q004261636B67726F756E645472616E73706172656E6379026Q00F03F03043Q0054657874034Q0003063Q005A496E646578026Q00284003053Q004672616D65030A3Q0066726F6D4F2Q66736574026Q002640030F3Q00426F7264657253697A65506978656C030B3Q00416E63686F72506F696E7403073Q00566563746F7232026Q00E03F03013Q005803063Q004F2Q66736574026Q00184003013Q005903103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q00444003083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D026Q00084003093Q00546578744C6162656C025Q00406540026Q003240030A3Q0054657874436F6C6F7233025Q00E06F4003043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q002440030E3Q005465787458416C69676E6D656E7403043Q004C65667403053Q007461626C6503063Q00696E7365727403073Q00546F2Q676C65732Q033Q006F626A2Q033Q007461622Q033Q006B6579030B3Q00637573746F6D436F6C6F7203113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E656374069D3Q001248000600013Q00202Q00060006000200122Q000700036Q00088Q00060008000200122Q000700053Q00202Q00070007000200122Q000800063Q00122Q000900073Q00122Q000A00063Q00122Q000B00086Q0007000B000200102Q00060004000700102Q00060009000100302Q0006000A000B00302Q0006000C000D00302Q0006000E000F00122Q000700013Q00202Q00070007000200122Q000800106Q00098Q00070009000200122Q000800053Q00202Q00080008001100122Q0009000F3Q00122Q000A000F6Q0008000A000200102Q00070004000800302Q0007000E001200302Q00070013000600122Q000800153Q00202Q00080008000200122Q000900163Q00122Q000A00166Q0008000A000200102Q00070014000800122Q000800053Q00202Q00080008000200122Q000900063Q00202Q000A0001001700202Q000A000A001800202Q000A000A001900122Q000B00063Q00202Q000C0001001A00202Q000C000C001800202Q000C000C00124Q0008000C000200102Q00070009000800122Q0008001C3Q00202Q00080008001D00122Q0009001E3Q00122Q000A001E3Q00122Q000B001E6Q0008000B000200102Q0007001B000800122Q000800013Q00202Q00080008000200122Q0009001F6Q000A00076Q0008000A000200122Q000900213Q00202Q00090009000200122Q000A00063Q00122Q000B00226Q0009000B000200102Q00080020000900122Q000800013Q00202Q00080008000200122Q000900106Q000A00076Q0008000A000200122Q000900053Q00202Q00090009000200122Q000A000B3Q00122Q000B00063Q00122Q000C000B3Q00122Q000D00066Q0009000D000200102Q00080004000900302Q0008000E000F0030A700080013000600122C000900013Q00202Q00090009000200122Q000A001F6Q000B00086Q0009000B000200122Q000A00213Q00202Q000A000A000200122Q000B00063Q00122Q000C00226Q000A000C000200102Q00090020000A00122Q000900013Q00202Q00090009000200122Q000A00236Q000B8Q0009000B000200122Q000A00053Q00202Q000A000A000200122Q000B00063Q00122Q000C00243Q00122Q000D00063Q00122Q000E00086Q000A000E000200102Q00090004000A00122Q000A00053Q00202Q000A000A000200122Q000B00063Q00202Q000C0001001700202Q000C000C001800202Q000C000C002500122Q000D00063Q00202Q000E0001001A00202Q000E000E00184Q000A000E000200102Q00090009000A00302Q0009000A000B00102Q0009000C3Q00062Q000A007E00010005000413012Q007E000100128C000A001C3Q002060000A000A001D00122Q000B00273Q00122Q000C00273Q00122Q000D00276Q000A000D00020010C100090026000A001201000A00293Q00202Q000A000A002800202Q000A000A002A00102Q00090028000A00302Q0009002B002C00122Q000A00293Q00202Q000A000A002D00202Q000A000A002E00102Q0009002D000A00302Q0009000E001200122Q000A002F3Q00202Q000A000A00304Q000B00013Q00202Q000B000B00314Q000C3Q000400102Q000C0032000800102Q000C0033000200102Q000C0034000300102Q000C003500054Q000A000C000100202Q000A0006003600202Q000A000A0037000618010C3Q000100052Q000E012Q00024Q000E012Q00034Q000E012Q00074Q00553Q00024Q000E012Q00044Q00A8000A000C00012Q00F73Q00013Q00013Q000F3Q0003043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574026Q002E4003063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E6577029A5Q99D93F03043Q00456E756D030B3Q00456173696E675374796C6503073Q00456C6173746963030F3Q00456173696E67446972656374696F6E2Q033Q004F7574026Q00284003043Q00506C6179002E4Q00AF9Q00000100016Q00028Q000300016Q0002000200034Q000200028Q000100026Q00023Q00122Q000100023Q00202Q00010001000300122Q000200043Q00122Q000300046Q00010003000200104Q000100016Q00033Q00206Q00054Q000200023Q00122Q000300063Q00202Q00030003000700122Q000400083Q00122Q000500093Q00202Q00050005000A00202Q00050005000B00122Q000600093Q00202Q00060006000C00202Q00060006000D4Q0003000600024Q00043Q000100122Q000500023Q00202Q00050005000300122Q0006000E3Q00122Q0007000E6Q00050007000200102Q0004000100056Q0004000200206Q000F6Q000200016Q00043Q00064Q002D00013Q000413012Q002D00012Q00553Q00044Q005500016Q0055000200014Q002F0001000100022Q00D93Q000200012Q00F73Q00017Q000F3Q0003063Q004F2Q6673657403073Q00566563746F72322Q033Q006E6577026Q00F0BF028Q0003063Q0043726561746503093Q0054772Q656E496E666F027Q004003043Q00456E756D030B3Q00456173696E675374796C6503043Q0053696E65030F3Q00456173696E67446972656374696F6E03053Q00496E4F7574026Q00F03F03043Q00506C617901203Q0012C4000100023Q00202Q00010001000300122Q000200043Q00122Q000300056Q00010003000200104Q000100014Q00015Q00202Q0001000100064Q00035Q00122Q000400073Q00202Q00040004000300122Q000500083Q00122Q000600093Q00202Q00060006000A00202Q00060006000B00122Q000700093Q00202Q00070007000C00202Q00070007000D00122Q000800046Q000900016Q0004000900024Q00053Q000100122Q000600023Q00202Q00060006000300122Q0007000E3Q00122Q000800056Q00060008000200102Q0005000100064Q00010005000200202Q00010001000F4Q0001000200016Q00017Q00393Q0003083Q00496E7374616E63652Q033Q006E657703093Q00546578744C6162656C03043Q0053697A6503053Q005544696D32028Q00025Q00C06740026Q002E4003083Q00506F736974696F6E03163Q004261636B67726F756E645472616E73706172656E6379026Q00F03F03043Q005465787403023Q003A20030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q00694003043Q00466F6E7403043Q00456E756D03063Q00476F7468616D03083Q005465787453697A65026Q002240030E3Q005465787458416C69676E6D656E7403043Q004C65667403063Q005A496E646578026Q002640030A3Q005465787442752Q746F6E025Q00806640026Q002C40026Q00304003103Q004261636B67726F756E64436F6C6F7233026Q004440026Q004640034Q00030F3Q00426F7264657253697A65506978656C03083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D026Q00104003053Q004672616D65026Q002840030A3Q0055494772616469656E742Q033Q006F626A03043Q0067726164030B3Q00637573746F6D436F6C6F7203053Q006C6162656C2Q033Q006D696E2Q033Q006D617803063Q007478744F626A03133Q0075706461746545787465726E616C56616C756503053Q007461626C6503063Q00696E7365727403073Q00536C6964657273030A3Q00496E707574426567616E03073Q00436F2Q6E656374030A3Q00496E707574456E646564030D3Q0052656E6465725374652Q70656407AF3Q0012C0000700013Q00202Q00070007000200122Q000800036Q00098Q00070009000200122Q000800053Q00202Q00080008000200122Q000900063Q00122Q000A00073Q00122Q000B00063Q00122Q000C00086Q0008000C000200102Q00070004000800102Q00070009000100302Q0007000A000B4Q00085Q00122Q0009000D6Q000A00046Q00080008000A00102Q0007000C000800122Q0008000F3Q00202Q00080008001000122Q000900113Q00122Q000A00113Q00122Q000B00116Q0008000B000200102Q0007000E000800122Q000800133Q00202Q00080008001200202Q00080008001400102Q00070012000800302Q00070015001600122Q000800133Q00202Q00080008001700202Q00080008001800102Q00070017000800302Q00070019001A00122Q000800013Q00202Q00080008000200122Q0009001B6Q000A8Q0008000A000200122Q000900053Q00202Q00090009000200122Q000A00063Q00122Q000B001C3Q00122Q000C00063Q00122Q000D001D6Q0009000D000200102Q00080004000900122Q000900053Q00202Q00090009000200122Q000A00063Q00122Q000B00063Q00122Q000C00063Q00122Q000D001E6Q0009000D00024Q00090001000900102Q00080009000900122Q0009000F3Q00202Q00090009001000122Q000A00203Q00122Q000B00203Q00122Q000C00216Q0009000C000200102Q0008001F000900302Q0008000C002200302Q00080019001A00302Q00080023000600122Q000900013Q00202Q00090009000200122Q000A00246Q000B00086Q0009000B000200122Q000A00263Q00202Q000A000A000200122Q000B00063Q00122Q000C00276Q000A000C000200102Q00090025000A00128C000900013Q00201501090009000200122Q000A00286Q000B00086Q0009000B000200122Q000A00053Q00202Q000A000A00024Q000B000400024Q000C000300024Q000B000B000C00122Q000C00063Q00122Q000D000B3Q00122Q000E00066Q000A000E000200102Q00090004000A00302Q00090019002900302Q00090023000600122Q000A000F3Q00202Q000A000A000200122Q000B000B3Q00122Q000C000B3Q00122Q000D000B6Q000A000D000200102Q0009001F000A00122Q000A00013Q00202Q000A000A000200122Q000B00246Q000C00096Q000A000C000200122Q000B00263Q00202Q000B000B000200122Q000C00063Q00122Q000D00276Q000B000D000200102Q000A0025000B00122Q000A00013Q00202Q000A000A000200122Q000B002A6Q000C00096Q000A000C00024Q000B3Q000800102Q000B002B000900102Q000B002C000A00102Q000B002D000600102Q000B002E3Q00102Q000B002F000200102Q000B0030000300102Q000B0031000700102Q000B0032000500122Q000C00333Q00202Q000C000C00344Q000D00013Q00202Q000D000D00354Q000E000B6Q000C000E00014Q000C00026Q000D000A6Q000C000200014Q000C5Q00202Q000D0008003600202Q000D000D0037000618010F3Q000100012Q000E012Q000C4Q0089000D000F000100122Q000D00333Q00202Q000D000D00344Q000E00036Q000F00043Q00202Q000F000F003800202Q000F000F003700061801110001000100012Q000E012Q000C4Q0044000F00116Q000D3Q000100122Q000D00333Q00202Q000D000D00344Q000E00036Q000F00053Q00202Q000F000F003900202Q000F000F0037000618011100020001000A2Q000E012Q000C4Q00553Q00044Q000E012Q00084Q000E012Q00024Q000E012Q00034Q00553Q00064Q000E012Q00094Q000E012Q00074Q000E017Q000E012Q00054Q0002010F00114Q00D4000D3Q00012Q0029000B00024Q00F73Q00013Q00033Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3101093Q0020D600013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001000800010002000413012Q000800012Q00ED000100014Q00C200016Q00F73Q00017Q00033Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3101093Q0020D600013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001000800010002000413012Q000800012Q00ED00016Q00C200016Q00F73Q00017Q00183Q0003103Q004765744D6F7573654C6F636174696F6E03043Q006D61746803053Q00636C616D7003013Q005803103Q004162736F6C757465506F736974696F6E030C3Q004162736F6C75746553697A65028Q00026Q00F03F026Q00244003053Q00666C2Q6F7203063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E6577029A5Q99B93F03043Q00456E756D030B3Q00456173696E675374796C6503043Q0051756164030F3Q00456173696E67446972656374696F6E2Q033Q004F757403043Q0053697A6503053Q005544696D3203043Q00506C617903043Q005465787403023Q003A20004B4Q00557Q00064E3Q004A00013Q000413012Q004A00012Q00553Q00013Q0020285Q00016Q0002000200122Q000100023Q00202Q00010001000300202Q00023Q00044Q000300023Q00202Q00030003000500202Q0003000300044Q0002000200034Q000300023Q00202Q00030003000600202Q0003000300044Q00020002000300122Q000300073Q00122Q000400086Q0001000400024Q000200036Q000300046Q000400036Q0003000300044Q0003000100034Q0002000200034Q000300043Q000E2Q0009002300010003000413012Q0023000100128C000300023Q00203400030003000A2Q000E010400024Q000A0003000200020006EC0002002800010003000413012Q0028000100128C000300023Q00203400030003000A00206F0004000200092Q000A0003000200020020780002000300092Q0055000300053Q00208700030003000B4Q000500063Q00122Q0006000C3Q00202Q00060006000D00122Q0007000E3Q00122Q0008000F3Q00202Q00080008001000202Q00080008001100122Q0009000F3Q00202Q00090009001200202Q0009000900134Q0006000900024Q00073Q000100122Q000800153Q00202Q00080008000D4Q000900013Q00122Q000A00073Q00122Q000B00083Q00122Q000C00076Q0008000C000200102Q0007001400084Q00030007000200202Q0003000300164Q0003000200014Q000300076Q000400083Q00122Q000500186Q000600026Q00040004000600102Q0003001700044Q000300096Q000400026Q0003000200012Q00F73Q00017Q00353Q0003083Q00496E7374616E63652Q033Q006E657703053Q004672616D6503043Q0053697A6503053Q005544696D32028Q00025Q00806640026Q00344003083Q00506F736974696F6E03103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003E4003063Q005A496E646578026Q002E40030F3Q00426F7264657253697A65506978656C03083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D026Q00104003023Q003A2003093Q00546578744C6162656C026Q00F03F026Q0034C0026Q00144003163Q004261636B67726F756E645472616E73706172656E637903043Q0054657874030A3Q0054657874436F6C6F7233026Q00694003043Q00466F6E7403043Q00456E756D03063Q00476F7468616D03083Q005465787453697A65026Q002240030E3Q005465787458416C69676E6D656E7403043Q004C656674026Q003040030A3Q005465787442752Q746F6E03043Q00E296BC20025Q00C0624003053Q005269676874026Q002040026Q003140027Q0040026Q00394003073Q0056697369626C650100026Q00494003063Q00697061697273025Q00E06F40025Q0080494003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637405E83Q00125D000500013Q00202Q00050005000200122Q000600036Q00078Q00050007000200122Q000600053Q00202Q00060006000200122Q000700063Q00122Q000800073Q00122Q000900063Q00122Q000A00086Q0006000A000200102Q00050004000600102Q00050009000100122Q0006000B3Q00202Q00060006000C00122Q0007000D3Q00122Q0008000D3Q00122Q0009000D6Q00060009000200102Q0005000A000600302Q0005000E000F00302Q00050010000600122Q000600013Q00202Q00060006000200122Q000700116Q000800056Q00060008000200122Q000700133Q00202Q00070007000200122Q000800063Q00122Q000900146Q00070009000200102Q00060012000700062Q0004002A00013Q000413012Q002A00012Q000E01065Q0012F6000700154Q000E010800044Q00B90006000600080006510006002B00010001000413012Q002B00012Q000E01065Q00128C000700013Q0020AA00070007000200122Q000800166Q000900056Q00070009000200122Q000800053Q00202Q00080008000200122Q000900173Q00122Q000A00183Q00122Q000B00173Q00122Q000C00066Q0008000C000200102Q00070004000800122Q000800053Q00202Q00080008000200122Q000900063Q00122Q000A00193Q00122Q000B00063Q00122Q000C00066Q0008000C000200102Q00070009000800302Q0007001A001700102Q0007001B000600122Q0008000B3Q00202Q00080008000C00122Q0009001D3Q00122Q000A001D3Q00122Q000B001D6Q0008000B000200102Q0007001C000800122Q0008001F3Q00202Q00080008001E00202Q00080008002000102Q0007001E000800302Q00070021002200122Q0008001F3Q00202Q00080008002300202Q00080008002400102Q00070023000800302Q0007000E002500122Q000800013Q00202Q00080008000200122Q000900266Q000A00056Q0008000A000200122Q000900053Q00202Q00090009000200122Q000A00173Q00122Q000B00063Q00122Q000C00173Q00122Q000D00066Q0009000D000200102Q00080004000900302Q0008001A001700302Q0008001B002700122Q0009000B3Q00202Q00090009000C00122Q000A00283Q00122Q000B00283Q00122Q000C00286Q0009000C000200102Q0008001C000900122Q0009001F3Q00202Q00090009002300202Q00090009002900102Q00080023000900302Q00080021002A00302Q0008000E002B00122Q000900013Q00202Q00090009000200122Q000A00036Q000B00056Q0009000B000200122Q000A00053Q00202Q000A000A000200122Q000B00173Q00122Q000C00063Q00122Q000D00066Q000E00023Q00202Q000E000E00084Q000A000E00020010C100090004000A001265000A00053Q00202Q000A000A000200122Q000B00063Q00122Q000C00063Q00122Q000D00173Q00122Q000E002C6Q000A000E000200102Q00090009000A00122Q000A000B3Q00202Q000A000A000C00122Q000B002D3Q00122Q000C002D3Q00122Q000D002D6Q000A000D000200102Q0009000A000A00302Q0009002E002F00302Q0009000E003000302Q00090010000600122Q000A00013Q00202Q000A000A000200122Q000B00116Q000C00096Q000A000C000200122Q000B00133Q00202Q000B000B000200122Q000C00063Q00122Q000D00146Q000B000D000200102Q000A0012000B00122Q000A00316Q000B00026Q000A0002000C00044Q00E0000100128C000F00013Q002019010F000F000200122Q001000266Q001100096Q000F0011000200122Q001000053Q00202Q00100010000200122Q001100173Q00122Q001200063Q00122Q001300063Q00122Q001400086Q00100014000200102Q000F0004001000122Q001000053Q00202Q00100010000200122Q001100063Q00122Q001200063Q00122Q001300063Q00202Q0014000D001700202Q0014001400084Q00100014000200102Q000F0009001000122Q0010000B3Q00202Q00100010000C00122Q0011002D3Q00122Q0012002D3Q00122Q0013002D6Q00100013000200102Q000F000A001000102Q000F001B000E00122Q0010000B3Q00202Q00100010000C00122Q001100323Q00122Q001200323Q00122Q001300326Q00100013000200102Q000F001C001000122Q0010001F3Q00202Q00100010001E00202Q00100010002000102Q000F001E001000302Q000F000E003300302Q000F0010000600262Q000D00D600010017000413012Q00D6000100128C001000013Q0020A300100010000200122Q001100116Q0012000F6Q00100012000200122Q001100133Q00202Q00110011000200122Q001200063Q00122Q001300146Q00110013000200102Q0010001200110020340010000F003400201001100010003500061801123Q000100052Q000E012Q00034Q000E012Q000E4Q000E012Q00094Q000E012Q00074Q000E017Q00A80010001200012Q00CD000D5Q00062B000A009E00010002000413012Q009E0001002034000A00080034002010010A000A0035000618010C0001000100012Q000E012Q00094Q00A8000A000C00012Q00F73Q00013Q00023Q00043Q0003073Q0056697369626C65010003043Q005465787403023Q003A20000C4Q00DB9Q00000100018Q000200016Q00023Q00304Q000100026Q00036Q000100043Q00122Q000200046Q000300016Q00010001000300104Q000300016Q00017Q00013Q0003073Q0056697369626C6500064Q00C59Q0000015Q00202Q0001000100014Q000100013Q00104Q000100016Q00017Q00253Q00030C3Q00736574636C6970626F617264031D3Q00682Q7470733A2Q2F646973636F72642E2Q672F617037323572396D4565030B3Q00746F636C6970626F61726403083Q00496E7374616E63652Q033Q006E657703073Q0054657874426F7803043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574026Q00F03F03083Q00506F736974696F6E026Q0024C003043Q005465787403103Q00436C656172546578744F6E466F637573010003093Q004D756C74694C696E6503063Q005A496E646578030C3Q0043617074757265466F637573030E3Q0053656C656374696F6E5374617274030E3Q00437572736F72506F736974696F6E03063Q00737472696E672Q033Q006C656E03043Q007461736B03053Q00646566657203063Q0043726561746503093Q0054772Q656E496E666F029A5Q99C93F03043Q00456E756D030B3Q00456173696E675374796C6503043Q0051756164030F3Q00456173696E67446972656374696F6E2Q033Q004F757403103Q00546578745472616E73706172656E6379028Q0003043Q00506C617903053Q0064656C6179026Q000C40004C3Q00128C3Q00013Q00064E3Q000700013Q000413012Q0007000100128C3Q00013Q0012F6000100024Q00D93Q00020001000413012Q0032000100128C3Q00033Q00064E3Q000E00013Q000413012Q000E000100128C3Q00033Q0012F6000100024Q00D93Q00020001000413012Q0032000100128C3Q00043Q002017014Q000500122Q000100066Q00029Q000002000200122Q000100083Q00202Q00010001000900122Q0002000A3Q00122Q0003000A6Q00010003000200104Q0007000100122Q000100083Q00202Q00010001000900122Q0002000C3Q00122Q0003000C6Q00010003000200104Q000B000100304Q000D000200304Q000E000F00304Q0010000F00304Q0011000A00202Q00013Q00124Q00010002000100304Q0013000A00122Q000100153Q00202Q00010001001600202Q00023Q000D4Q00010002000200202Q00010001000A00104Q0014000100122Q000100173Q00202Q00010001001800061801023Q000100012Q000E017Q00D90001000200012Q00CD8Q00553Q00013Q0020E55Q00194Q000200023Q00122Q0003001A3Q00202Q00030003000500122Q0004001B3Q00122Q0005001C3Q00202Q00050005001D00202Q00050005001E00122Q0006001C3Q00202Q00060006001F00202Q0006000600204Q0003000600024Q00043Q000100302Q0004002100226Q0004000200206Q00236Q0002000100124Q00173Q00206Q002400122Q000100253Q00061801020001000100022Q00553Q00014Q00553Q00024Q00A83Q000200012Q00F73Q00013Q00023Q00023Q00030C3Q0052656C65617365466F63757303073Q0044657374726F7900074Q00FE7Q00206Q00016Q000200019Q0000206Q00026Q000200016Q00017Q000C3Q0003063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E6577029A5Q99D93F03043Q00456E756D030B3Q00456173696E675374796C6503043Q0051756164030F3Q00456173696E67446972656374696F6E03023Q00496E03103Q00546578745472616E73706172656E6379026Q00F03F03043Q00506C617900134Q003C7Q00206Q00014Q000200013Q00122Q000300023Q00202Q00030003000300122Q000400043Q00122Q000500053Q00202Q00050005000600202Q00050005000700122Q000600053Q00202Q00060006000800202Q0006000600094Q0003000600024Q00043Q000100302Q0004000A000B6Q0004000200206Q000C6Q000200016Q00017Q00233Q0003083Q00496E7374616E63652Q033Q006E657703053Q004672616D6503043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00804640026Q00304003083Q00506F736974696F6E03103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00804140030F3Q00426F7264657253697A65506978656C028Q0003083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D026Q001040030A3Q005465787442752Q746F6E026Q00F03F03163Q004261636B67726F756E645472616E73706172656E637903043Q005465787403043Q004E616D65030A3Q0054657874436F6C6F7233025Q00806B4003043Q00466F6E7403043Q00456E756D03043Q00436F646503083Q005465787453697A65026Q00244003063Q005A496E646578026Q002A4003113Q004D6F75736542752Q746F6E31436C69636B03073Q00436F2Q6E65637403483Q001295000300013Q00202Q00030003000200122Q000400036Q00058Q00030005000200122Q000400053Q00202Q00040004000600122Q000500073Q00122Q000600086Q00040006000200102Q00030004000400102Q000300093Q00122Q0004000B3Q00202Q00040004000C00122Q0005000D3Q00122Q0006000D3Q00122Q0007000D6Q00040007000200102Q0003000A000400302Q0003000E000F00122Q000400013Q00202Q00040004000200122Q000500106Q000600036Q00040006000200122Q000500123Q00202Q00050005000200122Q0006000F3Q00122Q000700136Q00050007000200102Q00040011000500122Q000400013Q00202Q00040004000200122Q000500146Q000600036Q00040006000200122Q000500053Q00202Q00050005000200122Q000600153Q00122Q0007000F3Q00122Q000800153Q00122Q0009000F6Q00050009000200102Q00040004000500302Q0004001600154Q00050001000200202Q00050005001800102Q00040017000500122Q0005000B3Q00202Q00050005000C00122Q0006001A3Q00122Q0007001A3Q00122Q0008001A6Q00050008000200102Q00040019000500122Q0005001C3Q00202Q00050005001B00202Q00050005001D00102Q0004001B000500302Q0004001E001F00302Q00040020002100202Q00050004002200202Q00050005002300061801073Q000100062Q00553Q00014Q000E012Q00044Q00553Q00024Q00553Q00034Q000E012Q00014Q000E012Q00024Q00A80005000700012Q00F73Q00013Q00013Q000A3Q0003043Q00546578742Q033Q003Q2E030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00E06F40025Q00C06240028Q00030A3Q00496E707574426567616E03073Q00436F2Q6E656374001E4Q00557Q00064E3Q000400013Q000413012Q000400012Q00F73Q00014Q00ED3Q00014Q00259Q003Q00013Q00304Q000100026Q00013Q00122Q000100043Q00202Q00010001000500122Q000200063Q00122Q000300073Q00122Q000400086Q00010004000200104Q000300019Q004Q000100023Q00202Q00010001000900202Q00010001000A00061801033Q000100062Q00553Q00034Q00553Q00044Q00553Q00054Q00553Q00014Q000E017Q00558Q00710001000300022Q000E012Q00014Q00F73Q00013Q00013Q00123Q00030D3Q0055736572496E7075745479706503043Q00456E756D03083Q004B6579626F61726403073Q004B6579436F646503093Q00546F2Q676C654B657903063Q0045736361706503043Q005465787403043Q004E616D65030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00806B40030A3Q00446973636F2Q6E65637403043Q007461736B03043Q0077616974029A5Q99B93F030C3Q004D6F75736542752Q746F6E31030C3Q004D6F75736542752Q746F6E3201563Q0020D600013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001003200010002000413012Q0032000100203400013Q00042Q005500025Q0020340002000200050006850001001A00010002000413012Q001A000100203400013Q000400128C000200023Q0020340002000200040020340002000200060006850001001A00010002000413012Q001A00012Q0055000100014Q001D010200023Q00202Q00033Q00044Q0001000200034Q000100033Q00202Q00023Q000400202Q00020002000800102Q00010007000200044Q002000012Q0055000100034Q00B8000200016Q000300026Q00020002000300202Q00020002000800102Q0001000700022Q0055000100033Q0012450002000A3Q00202Q00020002000B00122Q0003000C3Q00122Q0004000C3Q00122Q0005000C6Q00020005000200102Q0001000900024Q000100043Q00202Q00010001000D4Q00010002000100122Q0001000E3Q00202Q00010001000F00122Q000200106Q0001000200014Q00018Q000100053Q00044Q0055000100203400013Q000100128C000200023Q0020340002000200010020340002000200110006850001003E00010002000413012Q003E000100203400013Q000100128C000200023Q00203400020002000100203400020002001200062A0001005500010002000413012Q005500012Q0055000100034Q00B8000200016Q000300026Q00020002000300202Q00020002000800102Q0001000700022Q0055000100033Q00128C0002000A3Q00206000020002000B00122Q0003000C3Q00122Q0004000C3Q00122Q0005000C6Q00020005000200101A2Q01000900024Q000100043Q00202Q00010001000D4Q00010002000100122Q0001000E3Q00202Q00010001000F00122Q000200106Q0001000200014Q00018Q000100054Q00F73Q00017Q001C3Q0003083Q00496E7374616E63652Q033Q006E657703053Q004672616D6503043Q0053697A6503083Q00506F736974696F6E03103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003E40030F3Q00426F7264657253697A65506978656C028Q0003083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D026Q00104003093Q00546578744C6162656C03043Q004E616D6503053Q005544696D32026Q00F03F03163Q004261636B67726F756E645472616E73706172656E637903043Q0054657874030A3Q0054657874436F6C6F7233026Q006E4003043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q00264003383Q0012CE000300013Q00202Q00030003000200122Q000400036Q00058Q00030005000200102Q00030004000100102Q00030005000200122Q000400073Q00202Q00040004000800122Q000500093Q00122Q000600093Q00122Q000700096Q00040007000200102Q00030006000400302Q0003000A000B00122Q000400013Q00202Q00040004000200122Q0005000C6Q000600036Q00040006000200122Q0005000E3Q00202Q00050005000200122Q0006000B3Q00122Q0007000F6Q00050007000200102Q0004000D000500122Q000400013Q00202Q00040004000200122Q000500106Q000600036Q00040006000200302Q00040011001000122Q000500123Q00202Q00050005000200122Q000600133Q00122Q0007000B3Q00122Q000800133Q00122Q0009000B6Q00050009000200102Q00040004000500302Q00040014001300102Q000400153Q00122Q000500073Q00202Q00050005000800122Q000600173Q00122Q000700173Q00122Q000800176Q00050008000200102Q00040016000500122Q000500193Q00202Q00050005001800202Q00050005001A00102Q00040018000500302Q0004001B001C4Q000300028Q00017Q002A3Q0003053Q00526164617203053Q005363616C65026Q00344003043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574026Q00644003063Q004B6579485544025Q00406040025Q00C0594003053Q00706169727303043Q00456E756D03073Q004B6579436F646503013Q0057026Q00424003083Q00506F736974696F6E025Q00804740026Q00144003013Q0041026Q001840025Q0080464003013Q005303013Q0044026Q00564003053Q005370616365025Q00805D40026Q002840025Q0080554003093Q00546578744C6162656C03083Q005465787453697A6503043Q006D61746803053Q00636C616D70026Q002640026Q00384003083Q00546F70204C6566742Q033Q006E6577028Q00027Q004003093Q00546F70205269676874026Q00F03F030B3Q00426F2Q746F6D204C656674030C3Q00426F2Q746F6D205269676874000C013Q009E7Q00206Q000100206Q000200122Q000100036Q000200013Q00122Q000300053Q00202Q00030003000600102Q000400073Q00102Q000500076Q00030005000200102Q0002000400034Q00025Q00202Q00020002000800202Q0002000200024Q000300023Q00122Q000400053Q00202Q00040004000600102Q00050009000200102Q0006000A00024Q00040006000200102Q00030004000400122Q0003000B6Q000400036Q00030002000500044Q007A000100128C0008000C3Q00203400080008000D00203400080008000E00062A0006002B00010008000413012Q002B000100128C000800053Q00203500080008000600102Q0009000F000200102Q000A000F00024Q0008000A000200102Q00070004000800122Q000800053Q00202Q00080008000600102Q00090011000200102Q000A001200024Q0008000A000200102Q00070010000800044Q0072000100128C0008000C3Q00203400080008000D00203400080008001300062A0006003D00010008000413012Q003D000100128C000800053Q00203500080008000600102Q0009000F000200102Q000A000F00024Q0008000A000200102Q00070004000800122Q000800053Q00202Q00080008000600102Q00090014000200102Q000A001500024Q0008000A000200102Q00070010000800044Q0072000100128C0008000C3Q00203400080008000D00203400080008001600062A0006004F00010008000413012Q004F000100128C000800053Q00203500080008000600102Q0009000F000200102Q000A000F00024Q0008000A000200102Q00070004000800122Q000800053Q00202Q00080008000600102Q00090011000200102Q000A001500024Q0008000A000200102Q00070010000800044Q0072000100128C0008000C3Q00203400080008000D00203400080008001700062A0006006100010008000413012Q0061000100128C000800053Q00203500080008000600102Q0009000F000200102Q000A000F00024Q0008000A000200102Q00070004000800122Q000800053Q00202Q00080008000600102Q00090018000200102Q000A001500024Q0008000A000200102Q00070010000800044Q0072000100128C0008000C3Q00203400080008000D00203400080008001900062A0006007200010008000413012Q0072000100128C000800053Q00203F00080008000600102Q0009001A000200102Q000A001B00024Q0008000A000200102Q00070004000800122Q000800053Q00202Q00080008000600102Q00090014000200102Q000A001C00024Q0008000A000200102Q00070010000800203400080007001D0012180009001F3Q00202Q00090009002000102Q000A0021000200122Q000B00143Q00122Q000C00226Q0009000C000200102Q0008001E000900062B0003001900010002000413012Q001900012Q005500035Q00203400030003000100203400030003001000269C0003009B00010023000413012Q009B00012Q0055000300013Q00129D000400053Q00202Q00040004002400122Q000500256Q000600013Q00122Q000700256Q000800016Q00040008000200102Q0003001000044Q000300023Q00122Q000400053Q00202Q00040004002400122Q000500253Q00102Q000600073Q00202Q0006000600264Q00060001000600102Q00070009000200202Q0007000700264Q00060006000700122Q000700253Q00102Q000800076Q00080001000800202Q00080008001B4Q00040008000200102Q00030010000400044Q000B2Q012Q005500035Q00203400030003000100203400030003001000269C000300BF00010027000413012Q00BF00012Q0055000300013Q0012E1000400053Q00202Q00040004002400122Q000500283Q00102Q000600076Q000600066Q00060006000100122Q000700256Q000800016Q00040008000200102Q0003001000044Q000300023Q00122Q000400053Q00202Q00040004002400122Q000500283Q00102Q000600076Q000600066Q00060006000100102Q000700073Q00202Q0007000700264Q00060006000700102Q00070009000200202Q0007000700264Q00060006000700122Q000700253Q00102Q000800076Q00080001000800202Q00080008001B4Q00040008000200102Q00030010000400044Q000B2Q012Q005500035Q00203400030003000100203400030003001000269C000300E300010029000413012Q00E300012Q0055000300013Q0012D2000400053Q00202Q00040004002400122Q000500256Q000600013Q00122Q000700283Q00102Q000800076Q000800086Q0008000800014Q00040008000200102Q0003001000044Q000300023Q00122Q000400053Q00202Q00040004002400122Q000500253Q00102Q000600073Q00202Q0006000600264Q00060001000600102Q00070009000200202Q0007000700264Q00060006000700122Q000700283Q00102Q000800076Q000800086Q00080008000100102Q000900076Q00080008000900202Q00080008001B4Q00040008000200102Q00030010000400044Q000B2Q012Q005500035Q00203400030003000100203400030003001000269C0003000B2Q01002A000413012Q000B2Q012Q0055000300013Q001269000400053Q00202Q00040004002400122Q000500283Q00102Q000600076Q000600066Q00060006000100122Q000700283Q00102Q000800076Q000800086Q0008000800014Q00040008000200102Q0003001000044Q000300023Q00122Q000400053Q00202Q00040004002400122Q000500283Q00102Q000600076Q000600066Q00060006000100102Q000700073Q00202Q0007000700264Q00060006000700102Q00070009000200202Q0007000700264Q00060006000700122Q000700283Q00102Q000800076Q000800086Q00080008000100102Q000900076Q00080008000900202Q00080008001B4Q00040008000200102Q0003001000042Q00F73Q00017Q00023Q0003073Q004B6579436F64653Q01094Q005500015Q00203400023Q00012Q002F00010001000200064E0001000800013Q000413012Q000800012Q0055000100013Q00203400023Q00010020040001000200022Q00F73Q00017Q00023Q0003073Q004B6579436F6465010001094Q005500015Q00203400023Q00012Q002F00010001000200064E0001000800013Q000413012Q000800012Q0055000100013Q00203400023Q00010020040001000200022Q00F73Q00017Q00023Q0003053Q00526164617203053Q00436F6C6F7201064Q009200015Q00202Q0001000100014Q000200016Q000200023Q00102Q0001000200026Q00017Q00023Q0003053Q00526164617203083Q00506F736974696F6E01064Q002100015Q00202Q00010001000100102Q000100026Q000100016Q0001000100016Q00017Q00023Q0003053Q00526164617203053Q005363616C6501064Q002100015Q00202Q00010001000100102Q000100026Q000100016Q0001000100016Q00017Q00023Q002Q033Q0045535003083Q00426F78436F6C6F7201064Q009200015Q00202Q0001000100014Q000200016Q000200023Q00102Q0001000200026Q00017Q00023Q002Q033Q0045535003053Q00436F6C6F7201064Q009200015Q00202Q0001000100014Q000200016Q000200023Q00102Q0001000200026Q00017Q00023Q0003073Q005472616365727303053Q00436F6C6F7201064Q009200015Q00202Q0001000100014Q000200016Q000200023Q00102Q0001000200026Q00017Q00043Q002Q033Q00464F5603093Q00776F726B7370616365030D3Q0043752Q72656E7443616D657261030B3Q004669656C644F6656696577010A4Q00DE00015Q00102Q000100013Q00122Q000100023Q00202Q00010001000300062Q0001000900013Q000413012Q0009000100128C000100023Q0020340001000100030010C1000100044Q00F73Q00017Q00023Q0003053Q00576F726C64030A3Q0053617475726174696F6E01044Q005500015Q0020340001000100010010C1000100024Q00F73Q00017Q00023Q0003053Q00576F726C6403083Q00436F6E747261737401044Q005500015Q0020340001000100010010C1000100024Q00F73Q00017Q00013Q0003073Q0056697369626C6501034Q005500015Q0010C1000100014Q00F73Q00017Q00023Q002Q033Q0047554903083Q00465053436F6C6F7201064Q009200015Q00202Q0001000100014Q000200016Q000200023Q00102Q0001000200026Q00017Q00033Q002Q033Q0047554903073Q0046502Q53697A6503083Q005465787453697A6501064Q005700015Q00202Q00010001000100102Q000100026Q000100013Q00102Q000100038Q00017Q00023Q0003053Q00417564696F03063Q00566F6C756D6501064Q002100015Q00202Q00010001000100102Q000100026Q000100016Q0001000100016Q00017Q00023Q0003053Q00417564696F03053Q00506974636801064Q002100015Q00202Q00010001000100102Q000100026Q000100016Q0001000100016Q00019Q003Q00034Q00558Q00913Q000100012Q00F73Q00017Q00023Q0003053Q00576F726C64030D3Q004D6178545044697374616E636501044Q005500015Q0020340001000100010010C1000100024Q00F73Q00019Q002Q0001053Q0006513Q000400010001000413012Q000400012Q00ED000100014Q00C200016Q00F73Q00017Q00023Q0003053Q00576F726C64030E3Q0057616C6B53702Q656456616C756501044Q005500015Q0020340001000100010010C1000100024Q00F73Q00017Q00103Q0003063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E6577029A5Q99D93F03043Q00456E756D030B3Q00456173696E675374796C6503043Q0051756164030F3Q00456173696E67446972656374696F6E2Q033Q004F757403163Q004261636B67726F756E645472616E73706172656E6379026Q00F03F03043Q00506C6179026Q33D33F03103Q00546578745472616E73706172656E637903043Q007461736B03053Q00737061776E003D4Q00467Q00206Q00014Q000200013Q00122Q000300023Q00202Q00030003000300122Q000400043Q00122Q000500053Q00202Q00050005000600202Q00050005000700122Q000600053Q00202Q00060006000800202Q0006000600094Q0003000600024Q00043Q000100302Q0004000A000B6Q0004000200206Q000C6Q000200019Q0000206Q00014Q000200023Q00122Q000300023Q00202Q00030003000300122Q0004000D3Q00122Q000500053Q00202Q00050005000600202Q00050005000700122Q000600053Q00202Q00060006000800202Q0006000600094Q0003000600024Q00043Q000100302Q0004000E000B6Q0004000200206Q000C6Q000200019Q0000206Q00014Q000200033Q00122Q000300023Q00202Q00030003000300122Q0004000D3Q00122Q000500053Q00202Q00050005000600202Q00050005000700122Q000600053Q00202Q00060006000800202Q0006000600094Q0003000600024Q00043Q000200302Q0004000E000B00302Q0004000A000B6Q0004000200206Q000C6Q0002000100124Q000F3Q00206Q00100006182Q013Q000100012Q00553Q00014Q00D93Q000200012Q00F73Q00013Q00013Q00053Q0003043Q007461736B03043Q0077616974029A5Q99D93F03073Q0056697369626C65012Q00073Q0012623Q00013Q00206Q000200122Q000100038Q000200019Q0000304Q000400056Q00017Q001D3Q0003073Q0056697369626C6503053Q004D6F64616C030D3Q004D6F7573654265686176696F7203043Q00456E756D03073Q0044656661756C7403053Q007063612Q6C03063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E6577026Q66D63F030B3Q00456173696E675374796C6503053Q005175617274030F3Q00456173696E67446972656374696F6E2Q033Q004F757403083Q00506F736974696F6E03113Q0047726F75705472616E73706172656E6379028Q0003043Q00506C617903043Q0053697A65026Q003440026Q00D03F03023Q00496E03053Q005544696D3203013Q005803053Q005363616C6503063Q004F2Q66736574025Q003081C0026Q00F03F029A5Q99C93F00704Q00099Q009Q009Q003Q00016Q00015Q00104Q000100016Q00016Q00015Q00104Q000200019Q0000064Q003C00013Q000413012Q003C00012Q00553Q00023Q00121E2Q0100043Q00202Q00010001000300202Q00010001000500104Q0003000100124Q00063Q0006182Q013Q000100012Q00553Q00024Q00813Q000200016Q00033Q00206Q00074Q000200043Q00122Q000300083Q00202Q00030003000900122Q0004000A3Q00122Q000500043Q00202Q00050005000B00202Q00050005000C00122Q000600043Q00202Q00060006000D00202Q00060006000E4Q0003000600024Q00043Q00024Q000500053Q00102Q0004000F000500302Q0004001000116Q0004000200206Q00126Q000200016Q00033Q00206Q00074Q000200063Q00122Q000300083Q00202Q00030003000900122Q0004000A3Q00122Q000500043Q00202Q00050005000B00202Q00050005000C00122Q000600043Q00202Q00060006000D00202Q00060006000E4Q0003000600024Q00043Q000100302Q0004001300146Q0004000200206Q00126Q0002000100044Q006F00012Q00553Q00043Q0020E95Q000F6Q00058Q00033Q00206Q00074Q000200043Q00122Q000300083Q00202Q00030003000900122Q000400153Q00122Q000500043Q00202Q00050005000B00202Q00050005000C00122Q000600043Q00202Q00060006000D00202Q0006000600164Q0003000600024Q00043Q000200122Q000500173Q00202Q0005000500094Q000600053Q00202Q00060006001800202Q0006000600194Q000700053Q00202Q00070007001800202Q00070007001A00122Q000800113Q00122Q0009001B6Q00050009000200102Q0004000F000500302Q00040010001C6Q0004000200206Q00126Q000200016Q00033Q00206Q00074Q000200063Q00122Q000300083Q00202Q00030003000900122Q0004001D3Q00122Q000500043Q00202Q00050005000B00202Q00050005000C00122Q000600043Q00202Q00060006000D00202Q0006000600164Q0003000600024Q00043Q000100302Q0004001300116Q0004000200206Q00126Q000200012Q00F73Q00013Q00013Q00023Q0003103Q004D6F75736549636F6E456E61626C65642Q0100034Q00557Q0030A73Q000100022Q00F73Q00017Q00023Q0003073Q004B6579436F646503093Q00546F2Q676C654B6579010B3Q00203400013Q00012Q005500025Q00203400020002000200062A0001000A00010002000413012Q000A00012Q0055000100013Q0006510001000A00010001000413012Q000A00012Q0055000100024Q00910001000100012Q00F73Q00017Q00043Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3103083Q00506F736974696F6E010E3Q0020D600013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001000D00010002000413012Q000D00012Q00ED000100014Q004B00015Q00202Q00013Q00044Q000100016Q000100033Q00202Q0001000100044Q000100024Q00F73Q00017Q000E3Q0003143Q0049734D6F75736542752Q746F6E5072652Q73656403043Q00456E756D030D3Q0055736572496E70757454797065030C3Q004D6F75736542752Q746F6E3103103Q004765744D6F7573654C6F636174696F6E03073Q00566563746F72332Q033Q006E657703013Q005803013Q0059028Q0003083Q00506F736974696F6E03053Q005544696D3203053Q005363616C6503063Q004F2Q66736574002F4Q00557Q00064E3Q002E00013Q000413012Q002E00012Q00553Q00013Q00200F014Q000100122Q000200023Q00202Q00020002000300202Q0002000200046Q0002000200064Q000E00010001000413012Q000E00012Q00ED8Q00C27Q000413012Q002E00012Q00553Q00013Q0020835Q00056Q0002000200122Q000100063Q00202Q00010001000700202Q00023Q000800202Q00033Q000900122Q0004000A6Q0001000400024Q000200026Q0001000100024Q000200033Q00122Q0003000C3Q00202Q0003000300074Q000400043Q00202Q00040004000800202Q00040004000D4Q000500043Q00202Q00050005000800202Q00050005000E00202Q0006000100084Q0005000500064Q000600043Q00202Q00060006000900202Q00060006000D4Q000700043Q00202Q00070007000900202Q00070007000E00202Q0008000100094Q0007000700084Q00030007000200102Q0002000B00032Q00F73Q00019Q002Q0001044Q005500016Q000E01026Q00D90001000200012Q00F73Q00017Q00893Q0003063Q00436F6C6F723303073Q0066726F6D48535603043Q007469636B026Q001440026Q00F03F2Q033Q004755492Q033Q0052474203053Q00436F6C6F7203053Q00526164617203063Q004B6579485544030C3Q004261636B6C69676874524742030E3Q004261636B6C69676874436F6C6F7203073Q005465787452474203093Q0054657874436F6C6F7203063Q0046505352474203083Q00465053436F6C6F7203073Q005472616365727303043Q004C657270026Q33C33F030A3Q0054657874436F6C6F7233030D3Q004D6F7573654265686176696F7203043Q00456E756D03073Q0044656661756C7403053Q007063612Q6C03063Q0069706169727303073Q00546F2Q676C65732Q033Q007461622Q033Q006B6579030B3Q00637573746F6D436F6C6F7203073Q0066726F6D524742026Q0044402Q033Q006F626A03103Q004261636B67726F756E64436F6C6F723303163Q004261636B67726F756E645472616E73706172656E6379028Q0003073Q00536C696465727303053Q00546F48535603043Q0067726164030D3Q00436F6C6F7253657175656E63652Q033Q006E657703153Q00436F6C6F7253657175656E63654B6579706F696E74026Q00E03F03043Q006D61746803053Q00636C616D70026Q66D63F03073Q0056697369626C6503073Q00456E61626C656403053Q007061697273029A5Q99C93F03093Q00546578744C6162656C026Q003E4003093Q00776F726B7370616365030D3Q0043752Q72656E7443616D65726103093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403063Q00434672616D6503053Q00576F726C64030A3Q0046752Q6C62726967687403073Q00416D6269656E74025Q00E06F40030A3Q004272696768746E652Q73027Q0040030A3Q0053617475726174696F6E03083Q00436F6E747261737403153Q0046696E6446697273744368696C644F66436C612Q7303083Q0048756D616E6F696403103Q0057616C6B53702Q6564456E61626C656403093Q0057616C6B53702Q6564030E3Q0057616C6B53702Q656456616C756503123Q0043686172616374657257616C6B53702Q6564026Q003040030A3Q00476574506C617965727303063Q004865616C746803043Q005465616D0003083Q00496E7374616E636503053Q004672616D6503043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574030B3Q00416E63686F72506F696E7403073Q00566563746F723203083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D030D3Q00546F4F626A656374537061636503083Q00506F736974696F6E03053Q005363616C6503013Q005803013Q005A030C3Q004162736F6C75746553697A652Q01025Q00806B4001002Q033Q0045535003093Q005465616D436865636B03143Q00576F726C64546F56696577706F7274506F696E7403073Q0044726177696E6703043Q004C696E6503093Q00546869636B6E652Q73026Q00F83F030C3Q005472616E73706172656E637903043Q0046726F6D030C3Q0056696577706F727453697A6503013Q005903023Q00546F03093Q00486967686C6967687403043Q004E616D6503073Q0053544B5F45737003093Q0046692Q6C436F6C6F72030C3Q004F75746C696E65436F6C6F7203103Q0046692Q6C5472616E73706172656E637903053Q004E616D657303043Q00466F6E74030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q00284003163Q00546578745374726F6B655472616E73706172656E637903043Q0054657874026Q005940026Q003440025Q0080414003053Q00426F78657303043Q004865616403073Q00566563746F7233026Q0008402Q033Q00616273026Q002E40026Q004940030F3Q00426F7264657253697A65506978656C03083Q0055495374726F6B65030F3Q00412Q706C795374726F6B654D6F646503063Q00426F7264657202CD5QCCE43F03063Q00426F7852474203083Q00426F78436F6C6F72004A032Q00121B3Q00013Q00206Q000200122Q000100036Q00010001000200202Q00010001000400202Q00010001000400122Q000200053Q00122Q000300058Q000300024Q00015Q00202Q00010001000600202Q00010001000700062Q0001001000013Q000413012Q001000010006EC0001001300013Q000413012Q001300012Q005500015Q0020340001000100060020340001000100082Q005500025Q00203400020002000900203400020002000700064E0002001A00013Q000413012Q001A00010006EC0002001D00013Q000413012Q001D00012Q005500025Q0020340002000200090020340002000200082Q005500035Q00203400030003000A00203400030003000B00064E0003002400013Q000413012Q002400010006EC0003002700013Q000413012Q002700012Q005500035Q00203400030003000A00203400030003000C2Q005500045Q00203400040004000A00203400040004000D00064E0004002E00013Q000413012Q002E00010006EC0004003100013Q000413012Q003100012Q005500045Q00203400040004000A00203400040004000E2Q005500055Q00203400050005000600203400050005000F00064E0005003800013Q000413012Q003800010006EC0005003B00013Q000413012Q003B00012Q005500055Q0020340005000500060020340005000500102Q005500065Q00203400060006001100203400060006000700064E0006004200013Q000413012Q004200010006EC0006004500013Q000413012Q004500012Q005500065Q0020340006000600110020340006000600082Q0055000700013Q00209A0007000700124Q000900013Q00122Q000A00136Q0007000A00024Q000700016Q000700023Q00102Q0007001400054Q000700033Q00062Q0007005900013Q000413012Q005900012Q0055000700043Q00121E010800163Q00202Q00080008001500202Q00080008001700102Q00070015000800122Q000700183Q00061801083Q000100012Q00553Q00044Q00D900070002000100128C000700194Q0055000800053Q00203400080008001A2Q00C8000700020009000413012Q00820001002034000C000B001B002034000D000B001C2Q002F000C000C000D00064E000C006900013Q000413012Q00690001002034000C000B001D000651000C006F00010001000413012Q006F00012Q0055000C00013Q000651000C006F00010001000413012Q006F000100128C000C00013Q002060000C000C001E00122Q000D001F3Q00122Q000E001F3Q00122Q000F001F6Q000C000F0002002034000D000B0020002047000E000B002000202Q000E000E002100202Q000E000E00124Q0010000C3Q00122Q001100136Q000E0011000200102Q000D0021000E00202Q000D000B002000202Q000E000B001B00202Q000F000B001C4Q000E000E000F00062Q000E008000013Q000413012Q008000010012F6000E00233Q000651000E008100010001000413012Q008100010012F6000E00053Q0010C1000D0022000E00062B0007005E00010002000413012Q005E000100128C000700194Q0055000800053Q0020340008000800242Q00C8000700020009000413012Q00AF0001002034000C000B001D000651000C008D00010001000413012Q008D00012Q0055000C00013Q002010010D000C00252Q00CC000D0002000F00202Q0010000B002600122Q001100273Q00202Q0011001100284Q001200023Q00122Q001300293Q00202Q00130013002800122Q001400236Q0015000C6Q00130015000200122Q001400293Q00202Q00140014002800122Q0015002A3Q00122Q001600013Q00202Q0016001600024Q0017000D6Q0018000E3Q00122Q0019002B3Q00202Q00190019002C00202Q001A000F002D00122Q001B00233Q00122Q001C00056Q0019001C6Q00168Q00143Q000200122Q001500293Q00202Q00150015002800122Q001600056Q0017000C6Q001500176Q00123Q00012Q000A0011000200020010C100100008001100062B0007008900010002000413012Q008900012Q0055000700064Q001601085Q00202Q00080008000A00202Q00080008002F00102Q0007002E00084Q000700073Q00102Q00070021000200122Q000700306Q000800086Q00070002000900044Q00E700012Q0055000C00094Q002F000C000C000A00064E000C00D400013Q000413012Q00D40001002034000C000B00210020A1000C000C00124Q000E00033Q00122Q000F00316Q000C000F000200102Q000B0021000C00202Q000C000B003200202Q000D000B003200202Q000D000D001400202Q000D000D001200122Q000F00013Q00202Q000F000F002800122Q001000233Q00122Q001100233Q00122Q001200236Q000F0012000200122Q001000316Q000D0010000200102Q000C0014000D00044Q00E70001002034000C000B0021002011000C000C001200122Q000E00013Q00202Q000E000E001E00122Q000F00333Q00122Q001000333Q00122Q001100336Q000E0011000200122Q000F00316Q000C000F000200102Q000B0021000C00202Q000C000B003200202Q000D000B003200202Q000D000D001400202Q000D000D00124Q000F00043Q00122Q001000316Q000D0010000200102Q000C0014000D00062B000700BC00010002000413012Q00BC00012Q00550007000A4Q008B00085Q00202Q00080008000900202Q00080008002F00102Q0007002E000800122Q000700343Q00202Q00070007003500062Q000700FD00013Q000413012Q00FD00012Q00550008000B3Q00203400080008003600064E000800FD00013Q000413012Q00FD00012Q00550008000B3Q00201201080008003600202Q00080008003700122Q000A00386Q0008000A000200062Q000800072Q010001000413012Q00072Q0100128C000800304Q00550009000C4Q00C800080002000A000413012Q00042Q012Q0055000D000D4Q000E010E000B4Q00D9000D0002000100062B0008003Q010002000413012Q003Q012Q00F73Q00014Q00550008000B3Q00209000080008003600202Q00080008003800202Q0009000700394Q000A5Q00202Q000A000A003A00202Q000A000A003B00062Q000A001A2Q013Q000413012Q001A2Q012Q0055000A000E3Q0012A9000B00013Q00202Q000B000B001E00122Q000C003D3Q00122Q000D003D3Q00122Q000E003D6Q000B000E000200102Q000A003C000B4Q000A000E3Q00302Q000A003E003F2Q0055000A000F4Q0088000B5Q00202Q000B000B003A00202Q000B000B004000102Q000A0040000B4Q000A000F6Q000B5Q00202Q000B000B003A00202Q000B000B004100102Q000A0041000B4Q000A000B3Q00202Q000A000A003600202Q000A000A004200122Q000C00436Q000A000C000200062Q000A00422Q013Q000413012Q00422Q012Q0055000B5Q002034000B000B003A002034000B000B004400064E000B00372Q013Q000413012Q00372Q012Q0055000B5Q0020BA000B000B003A00202Q000B000B004600102Q000A0045000B4Q000B00016Q000B00103Q00044Q00422Q012Q0055000B00103Q00064E000B00422Q013Q000413012Q00422Q012Q0055000B00113Q002034000B000B0047000651000B003F2Q010001000413012Q003F2Q010012F6000B00483Q0010C1000A0045000B2Q00ED000B6Q00C2000B00103Q00128C000B00194Q002Q010C00123Q00202Q000C000C00494Q000C000D6Q000B3Q000D00044Q004703012Q00550010000B3Q000685000F004703010010000413012Q004703010020340010000F003600064E0010004403013Q000413012Q004403010020100111001000370012F6001300384Q007100110013000200064E0011004403013Q000413012Q004403010020100111001000420012F6001300434Q007100110013000200064E0011004403013Q000413012Q004403010020100111001000420012F6001300434Q007100110013000200203400110011004A000EF00023004403010011000413012Q004403010020340011001000380020340012000F004B2Q00550013000B3Q00203400130013004B00062A001200672Q010013000413012Q00672Q010020340012000F004B00269C001200682Q01004C000413012Q00682Q012Q003900126Q00ED001200014Q005500135Q00203400130013000900203400130013002F00064E001300C62Q013Q000413012Q00C62Q012Q00550013000C4Q002F00130013000F000651001300902Q010001000413012Q00902Q0100128C0013004D3Q00201400130013002800122Q0014004E6Q0015000A6Q00130015000200122Q001400503Q00202Q00140014005100122Q001500043Q00122Q001600046Q00140016000200102Q0013004F001400122Q001400533Q00202Q00140014002800122Q0015002A3Q00122Q0016002A6Q00140016000200102Q00130052001400122Q0014004D3Q00202Q00140014002800122Q001500546Q001600136Q00140016000200122Q001500563Q00202Q00150015002800122Q001600053Q00122Q001700236Q00150017000200102Q0014005500154Q0014000C6Q0014000F001300201001130009005700201D0015001100394Q00130015000200202Q0013001300584Q00145Q00202Q00140014000900202Q00140014005900102Q0014003F001400202Q00150013005A4Q00150015001400202Q00160013005B4Q0016001600144Q0017000A3Q00202Q00170017005C00202Q00170017005A00202Q00170017003F00202Q00180015003F00202Q00190016003F4Q00180018001900202Q00190017003F00062Q001800C22Q010019000413012Q00C22Q012Q00550018000C4Q006700180018000F00302Q0018002E005D4Q0018000C6Q00180018000F00122Q001900503Q00202Q00190019002800122Q001A002A6Q001B00153Q00122Q001C002A6Q001D00166Q0019001D000200102Q0018005800194Q0018000C6Q00180018000F00062Q001200BF2Q013Q000413012Q00BF2Q0100128C001900013Q00206000190019001E00122Q001A00233Q00122Q001B005E3Q00122Q001C003D6Q0019001C0002000651001900C02Q010001000413012Q00C02Q012Q000E011900023Q0010C1001800210019000413012Q00CD2Q012Q00550018000C4Q002F00180018000F0030A70018002E005F000413012Q00CD2Q012Q00550013000C4Q002F00130013000F00064E001300CD2Q013Q000413012Q00CD2Q012Q00550013000C4Q002F00130013000F0030A70013002E005F2Q005500135Q00203400130013006000203400130013000700064E001300D42Q013Q000413012Q00D42Q010006EC001300D72Q013Q000413012Q00D72Q012Q005500135Q0020340013001300600020340013001300082Q005500145Q00203400140014006000203400140014006100064E001400DF2Q013Q000413012Q00DF2Q012Q000D011400123Q000413012Q00E02Q012Q003900146Q00ED001400014Q005500155Q00203400150015001100203400150015006100064E001500E82Q013Q000413012Q00E82Q012Q000D011500123Q000413012Q00E92Q012Q003900156Q00ED001500013Q0020100116000700620020F10018001100584Q0016001800174Q00185Q00202Q00180018001100202Q00180018002F00062Q0018001B02013Q000413012Q001B020100064E0017001B02013Q000413012Q001B020100064E0015001B02013Q000413012Q001B02012Q0055001800134Q002F00180018000F0006510018000102010001000413012Q0001020100128C001800633Q00201B01180018002800122Q001900646Q00180002000200302Q00180065006600302Q0018006700054Q001900136Q0019000F00182Q0055001800134Q003A00180018000F00122Q001900533Q00202Q00190019002800202Q001A0007006900202Q001A001A005A00202Q001A001A003F00202Q001B0007006900202Q001B001B006A4Q0019001B000200102Q0018006800194Q001800136Q00180018000F00122Q001900533Q00202Q00190019002800202Q001A0016005A00202Q001B0016006A4Q0019001B000200102Q0018006B00194Q001800136Q00180018000F00102Q0018000800064Q001800136Q00180018000F00302Q0018002E005D00044Q002202012Q0055001800134Q002F00180018000F00064E0018002202013Q000413012Q002202012Q0055001800134Q002F00180018000F0030A70018002E005F2Q005500185Q00203400180018006000203400180018002F00064E0018002E03013Q000413012Q002E030100064E0014002E03013Q000413012Q002E03012Q0055001800144Q002F00180018000F0006510018003502010001000413012Q0035020100128C0018004D3Q00204C00180018002800122Q0019006C6Q001A00106Q0018001A000200302Q0018006D006E4Q001900146Q0019000F00182Q0055001800144Q001200180018000F00302Q0018002F005D4Q001800146Q00180018000F00102Q0018006F00134Q001800146Q00180018000F00122Q001900013Q00202Q00190019002800122Q001A00053Q00122Q001B00053Q00122Q001C00056Q0019001C000200102Q0018007000194Q001800146Q00180018000F00302Q00180071002A00062Q0017001F03013Q000413012Q001F03012Q005500185Q00203400180018006000203400180018007200064E001800A402013Q000413012Q00A402012Q0055001800154Q002F00180018000F0006510018006002010001000413012Q0060020100128C0018004D3Q0020E400180018002800122Q001900326Q001A00166Q0018001A000200302Q00180022000500122Q001900163Q00202Q00190019007300202Q00190019007400102Q00180073001900302Q00180075007600302Q0018007700234Q001900156Q0019000F00182Q0055001800154Q000C00180018000F00202Q0019000F006D00102Q0018007800194Q001800156Q00180018000F00102Q0018001400134Q001800156Q00180018000F00122Q001900503Q00202Q00190019005100122Q001A00793Q00122Q001B007A6Q0019001B000200102Q0018004F001900122Q0018007B6Q00195Q00202Q00190019006000202Q00190019007C00062Q0019009602013Q000413012Q009602010020100119001000370012F6001B007D4Q00710019001B000200064E0019009602013Q000413012Q00960201002010011A00070062002030001C0019005800122Q001D007E3Q00202Q001D001D002800122Q001E00233Q00122Q001F002A3Q00122Q002000236Q001D002000024Q001C001C001D4Q001A001C000200202Q001B0007006200202Q001D0011005800122Q001E007E3Q00202Q001E001E002800122Q001F00233Q00122Q0020007F3Q00122Q002100236Q001E002100024Q001D001D001E4Q001B001D000200122Q001C002B3Q00202Q001C001C008000202Q001D001A006A00202Q001E001B006A4Q001D001D001E4Q001C0002000200202Q001C001C003F00202Q0018001C00812Q0055001900154Q000701190019000F00122Q001A00503Q00202Q001A001A005100202Q001B0016005A00202Q001B001B008200202Q001C0016006A4Q001C001C00184Q001A001C000200102Q00190058001A4Q001900156Q00190019000F00302Q0019002E005D00044Q00AB02012Q0055001800154Q002F00180018000F00064E001800AB02013Q000413012Q00AB02012Q0055001800154Q002F00180018000F0030A70018002E005F2Q005500185Q00203400180018006000203400180018007C00064E0018001703013Q000413012Q001703012Q0055001800174Q002F00180018000F000651001800C702010001000413012Q00C7020100128C0018004D3Q0020E300180018002800122Q0019004E6Q001A00166Q0018001A000200302Q00180022000500302Q00180083000500122Q0019004D3Q00202Q00190019002800122Q001A00846Q001B00186Q0019001B000200302Q00190065006600122Q001A00163Q00202Q001A001A008500202Q001A001A008600102Q00190085001A4Q001A00176Q001A000F00180020100118001000370012F6001A007D4Q00710018001A000200064E0018000F03013Q000413012Q000F03010020100119000700620020BE001B0018005800122Q001C007E3Q00202Q001C001C002800122Q001D00233Q00122Q001E002A3Q00122Q001F00236Q001C001F00024Q001B001B001C4Q0019001B000200202Q001A0007006200202Q001C0011005800122Q001D007E3Q00202Q001D001D002800122Q001E00233Q00122Q001F007F3Q00122Q002000236Q001D002000024Q001C001C001D4Q001A001C000200122Q001B002B3Q00202Q001B001B008000202Q001C0019006A00202Q001D001A006A4Q001C001C001D4Q001B0002000200202Q001C001B00874Q001D00176Q001D001D000F00122Q001E00503Q00202Q001E001E00514Q001F001C6Q0020001B6Q001E0020000200102Q001D004F001E4Q001D00176Q001D001D000F00122Q001E00503Q00202Q001E001E005100202Q001F0016005A00202Q0020001C003F4Q001F001F002000202Q00200016006A00202Q0021001B003F4Q0020002000214Q001E0020000200102Q001D0058001E4Q001D00176Q001D001D000F00202Q001D001D004200122Q001F00846Q001D001F00024Q001E5Q00202Q001E001E006000202Q001E001E008800062Q001E000703013Q000413012Q000703010006EC001E000A03013Q000413012Q000A03012Q0055001E5Q002034001E001E0060002034001E001E00890010C1001D0008001E2Q0055001D00174Q002F001D001D000F0030A7001D002E005D000413012Q004703012Q0055001900174Q002F00190019000F00064E0019004703013Q000413012Q004703012Q0055001900174Q002F00190019000F0030A70019002E005F000413012Q004703012Q0055001800174Q002F00180018000F00064E0018004703013Q000413012Q004703012Q0055001800174Q002F00180018000F0030A70018002E005F000413012Q004703012Q0055001800154Q002F00180018000F00064E0018002603013Q000413012Q002603012Q0055001800154Q002F00180018000F0030A70018002E005F2Q0055001800174Q002F00180018000F00064E0018004703013Q000413012Q004703012Q0055001800174Q002F00180018000F0030A70018002E005F000413012Q004703012Q0055001800144Q002F00180018000F00064E0018003503013Q000413012Q003503012Q0055001800144Q002F00180018000F0030A70018002F005F2Q0055001800154Q002F00180018000F00064E0018003C03013Q000413012Q003C03012Q0055001800154Q002F00180018000F0030A70018002E005F2Q0055001800174Q002F00180018000F00064E0018004703013Q000413012Q004703012Q0055001800174Q002F00180018000F0030A70018002E005F000413012Q004703012Q00550011000D4Q000E0112000F4Q00D900110002000100062B000B00482Q010002000413012Q00482Q012Q00F73Q00013Q00013Q00023Q0003103Q004D6F75736549636F6E456E61626C65642Q0100034Q00557Q0030A73Q000100022Q00F73Q00017Q00113Q0003053Q00576F726C64030F3Q0054656C65706F7274456E61626C656403073Q004B6579436F6465030B3Q0054656C65706F72744B657903083Q004765744D6F75736503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F74506172742Q033Q0048697403083Q00506F736974696F6E03093Q004D61676E6974756465030D3Q004D6178545044697374616E636503063Q00434672616D652Q033Q006E657703073Q00566563746F7233028Q00026Q00084002373Q00064E0001000300013Q000413012Q000300012Q00F73Q00014Q005500025Q00203400020002000100203400020002000200064E0002003600013Q000413012Q0036000100203400023Q00032Q005500035Q00203400030003000100203400030003000400062A0002003600010003000413012Q003600012Q0055000200013Q0020100102000200052Q000A00020002000200064E0002003600013Q000413012Q003600012Q0055000300013Q00203400030003000600064E0003003600013Q000413012Q003600012Q0055000300013Q00201900030003000600202Q00030003000700122Q000500086Q00030005000200062Q0003003600013Q000413012Q003600012Q0055000300013Q0020F400030003000600202Q00030003000800202Q00040002000900202Q00040004000A00202Q00050003000A4Q00050004000500202Q00050005000B4Q00065Q00202Q00060006000100202Q00060006000C00062Q0005003600010006000413012Q0036000100128C0005000D3Q0020BC00050005000E00122Q0006000F3Q00202Q00060006000E00122Q000700103Q00122Q000800113Q00122Q000900106Q0006000900024Q0006000400064Q00050002000200102Q0003000D00052Q00F73Q00017Q00093Q0003053Q00576F726C6403073Q00496E664A756D7003093Q0043686172616374657203153Q0046696E6446697273744368696C644F66436C612Q7303083Q0048756D616E6F6964030B3Q004368616E6765537461746503043Q00456E756D03113Q0048756D616E6F696453746174655479706503073Q004A756D70696E67001B4Q00557Q0020345Q00010020345Q000200064E3Q001A00013Q000413012Q001A00012Q00553Q00013Q0020345Q000300064E3Q001A00013Q000413012Q001A00012Q00553Q00013Q0020195Q000300206Q000400122Q000200058Q0002000200064Q001A00013Q000413012Q001A00012Q00553Q00013Q0020C35Q000300206Q000400122Q000200058Q0002000200206Q000600122Q000200073Q00202Q00020002000800202Q0002000200096Q000200012Q00F73Q00017Q00", GetFEnv(), ...);
-- build
