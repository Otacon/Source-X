/**
* @file CVarFloat.h
* @brief Custom float implementation.
*/

#pragma once
#ifndef _INC_CVARFLOAT_H
#define _INC_CVARFLOAT_H

#include <map>
#include "./sphere_library/CString.h"


struct LexNoCaseLess {
	bool operator()(const CGString& CGStr, const char* pBeg2) const
	{
		const char* pBeg1 = CGStr.GetPtr();
		const char* pEnd1 = pBeg1;
		const char* pEnd2 = pBeg2;
		while (*pEnd1) 
			++pEnd1;
		while (*pEnd2)
			++pEnd2;
		++pEnd1, ++pEnd2;

  		for (; pBeg1 != pEnd1 && pBeg2 != pEnd2; ++pBeg1, ++pBeg2)
			if (tolower(*pBeg1) < tolower(*pBeg2))
				return (true);
			else if (tolower(*pBeg2) < tolower(*pBeg1))
				return (false);
		return (pBeg1 == pEnd1 && pBeg2 != pEnd2);
	}
};

class CVarFloat
{
public:
	typedef double RealType;
	typedef std::map<CGString, RealType, LexNoCaseLess> MapType;

public: //vars
	CVarFloat();
	~CVarFloat();

private:
	CVarFloat(const CVarFloat& copy);
	CVarFloat& operator=(const CVarFloat& other);

private: //vars
	MapType m_VarMap;

private: //setting, getting
	inline bool Set( const char* VarName, const char* VarValue );
	RealType GetVal( const char* VarName );
public: //setting, getting
	bool Insert( const char* VarName, const char* VarValue, bool ForceSet = false);
	CGString Get( const char* VarName );

public: //parsing
	static CGString FloatMath( lpctstr & Expr );
	static RealType MakeFloatMath( lpctstr & Expr );
	static RealType GetRandVal( RealType dQty );
	static RealType GetRandVal2( RealType dMin, RealType dMax );
	//Does not work as it should, would be too slow, and nobody needs that
	/*static RealType GetRange( lpctstr & pExpr );
	static int GetRangeVals( lpctstr & pExpr, RealType * piVals, short int iMaxQty );*/
private: //parsing
	static RealType GetValMath( RealType dVal, lpctstr & pExpr );
	static RealType GetSingle( lpctstr & pArgs );
};

class CObjBase;

class CLocalObjMap
{
public:
	CLocalObjMap();
	~CLocalObjMap();
private:
	CLocalObjMap(const CLocalObjMap& copy);
	CLocalObjMap& operator=(const CLocalObjMap& other);

public:
	CObjBase * Get( ushort Number );
	bool Insert( ushort Number, CObjBase * pObj, bool ForceSet = false );
	typedef std::map<ushort, CObjBase*> ObjMap;

private:
	ObjMap m_ObjMap;
};

#endif // _INC_CVARFLOAT_H