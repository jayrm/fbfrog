#ifdef A
	'' TODO: unknown construct
	EXPANDTHIS void f(void);
#else
	#ifdef B
		#define EXPANDTHIS
		declare sub f( )
	#else
		'' TODO: unknown construct
		EXPANDTHIS void f(void);
	#endif
#endif
