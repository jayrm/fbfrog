#ifdef A
	#ifdef B
		#define EXPANDTHIS
		declare sub f( )
	#else
		'' TODO: unknown construct
		EXPANDTHIS void f(void);
	#endif
#else
#endif
