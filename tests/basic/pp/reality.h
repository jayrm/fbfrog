#ifndef TEST_H
#define TEST_H

#define A               1
#define B               2
#define C \
                        3

/* PP expressions */
#if (!defined(FOO_BAR) && THIS_IS_INSANE >= 123) \
    || (OH_MAN_WHATS_THE_PRECEDENCE < 5 && (defined(OK) \
                                            || defined(I_DONT_KNOW)))
	#define PPMERGE(a, b) a##b
	#define PPSTRINGIZE(a) #a

#	if X == 4294967295UL || X == -1
#		define HOORAY
#	endif
#elif 1
	//#pragma foo
#endif

#define myDoSomething(a, b, c) doSomething(1, c, b, a, 0)

#endif