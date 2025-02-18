############ mlfs-tools-current-with-ada-builtin.sh #############################
#!/bin/bash
#
# Copyright 2018,2019,2020,2021  J. E. Garrott Sr, Puyallup, WA, USA
# Copyright 2018,2019,2020,2021  "nobodino", Bordeaux, FRANCE
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#--------------------------------------------------------------------------
#
# Note: Much of this script is inspired from the LFS manual chapter 5
#       Copyright © 1999-2019 Gerard Beekmans and may be
#       copied under the MIT License.
#
#--------------------------------------------------------------------------
#
# script to build 'tools' for Slackware From Scratch (SFS)
# script to be executed once 'su - mlfs' has been performed.
#
#
# It doesn't respect exactly the list of the packages given in the LFS book.
# Some packages needed for testing in the chapter 6 have been skipped.
# Some other packages have been added to be able to build slackware.
#
# Everything will be done automatically in this script.
#--------------------------------------------------------------------------
#
#	Above july 2018, revisions made through github project: 
#   https://github.com/nobodino/slackware-from-scratch 
# 
#*******************************************************************
# set -x
#*******************************************************************
# the directory where will be built slackware from scratch
#*******************************************************************
export MLFS=/mnt/mlfs
#*******************************************************************
# the directory where is stored the resynced slackware sources
#*******************************************************************
export RDIR=$MLFS/slacksrc
#*******************************************************************
# the directory where will be stored the slackware source for MLFS
#*******************************************************************
export SRCDIR=$MLFS/sources
# MLFS_TGT=$(uname -m)-mlfs-linux-gnu
# export MLFS_TGT
#*******************************************************************
# define the target MLFS is built for
#*******************************************************************
case $(uname -m) in
   x86_64)  export MLFS_TARGET="x86_64-mlfs-linux-musl"
            export MLFS_ARCH="x86"
            export MLFS_CPU="x86-64"
            ;;
   i686)    export MLFS_TARGET="i686-mlfs-linux-musl"
            export MLFS_ARCH="x86"
            export MLFS_CPU="i686"
            ;;
esac
#*******************************************************************
# define the HOST MLFS is built on
#*******************************************************************
export MLFS_HOST="$(echo $MACHTYPE | sed "s/$(echo $MACHTYPE | cut -d- -f2)/cross/")"
#*******************************************************************
# set your own MAKEFLAGS
#*******************************************************************
export MAKEFLAGS='-j 9'
#*******************************************************************
export GREEN="\\033[1;32m"
export NORMAL="\\033[0;39m"
export RED="\\033[1;31m"
export PINK="\\033[1;35m"
export BLUE="\\033[1;34m"
export YELLOW="\\033[1;33m"
#*******************************************************************


echo_begin () {
#*****************************
    echo
    echo "You have decided to build 'tools' for mlfs (aka Slackware From Scratch)."
    echo
    echo "You are at the end of paragraph 4.4 of LFS-8.1 book"
    echo
    echo "The last command you executed was:"
    echo
    echo -e "$GREEN" "source ~/.bash_profile" "$NORMAL" 
    echo
    echo "Your Slackware source packages are in: $RDIR"
    echo "Your MAKEFLAGS are: $MAKEFLAGS"
    echo "Are you ok with this?"
    echo
    echo "From now everything will be built automatically until the end."
    echo "When you're ready just press <1> for begin or <2> for quit."
    echo

    PS3="Your choice:"
    select build in begin quit
    do
        if [[ "$build" = "begin" ]]
        then
            break
        else [[ "$build" = "quit" ]]
            echo  -e "$GREEN" "You have decided to quit. Goodbye."  "$NORMAL" && exit 1
        fi
    done
    echo -e "$RED" "You choose to build 'tools' for MLFS." "$NORMAL"
}

ada_choice () {
#*****************************
	PS3="Your choice:"
	echo
	echo -e "$GREEN" "Do you want to build the tools with gnat ada: yes or no." "$NORMAL"
	echo
	select ada_enable in yes no
	do
		if [[ "$ada_enable" = "yes" ]]
		then
			echo
			echo -e "$RED" "You decided to build the tools with gnat ada. It will be quiet long" "$NORMAL"
			echo
			break
		elif [[ "$ada_enable" = "no" ]]
		then
			echo
			echo -e "$RED" "You decided to build the tools without gnat ada." "$NORMAL"
			echo -e "$YELLOW" "You may chose that option when building a minimal MLFS system with no gnat compiler." "$NORMAL"
			echo
			break
		fi
	done
}

copy_src () {
#*****************************
    cd $RDIR/a/bash/
	export BASHVER=${VERSION:-$(echo bash-*.tar.?z* | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
	cp -v $RDIR/a/bash/bash-$BASHVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/d/binutils
	export BINUVER=${VERSION:-$(echo binutils-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
    cp -v $RDIR/d/binutils/binutils-$BINUVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/d/bison
	export BISONVER=${VERSION:-$(echo bison-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
    cp -v $RDIR/d/bison/bison-$BISONVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/bzip2
	export BZIP2VER=${VERSION:-$(echo bzip2-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
    cp -v $RDIR/a/bzip2/bzip2-$BZIP2VER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/coreutils
	export COREVER=${VERSION:-$(echo coreutils-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/coreutils/coreutils-$COREVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/ap/diffutils
	export DIFFVER=${VERSION:-$(echo diffutils-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/ap/diffutils/diffutils-$DIFFVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/file
	export FILEVER=${VERSION:-$(echo file-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/file/file-$FILEVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/findutils
	export FINDVER=${VERSION:-$(echo findutils-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/findutils/findutils-$FINDVER.tar.lz $SRCDIR || exit 1
    cd $RDIR/a/gawk
	export GAWKVER=${VERSION:-$(echo gawk-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/gawk/gawk-$GAWKVER.tar.lz $SRCDIR || exit 1
    cd $RDIR/d/gcc
	export SRCVER=${VERSION:-$(echo gcc-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
	export GCCVER=$(echo $SRCVER | cut -f 1 -d _)
    cp -v $RDIR/d/gcc/gcc-$SRCVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/gettext
	export GETTVER=${VERSION:-$(echo gettext-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/gettext/gettext-$GETTVER.tar.lz $SRCDIR || exit 1
    cd $RDIR/l/glibc
#	export GLIBCVER=${VERSION:-$(echo glibc-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
#   cp -v $RDIR/l/glibc/glibc-$GLIBCVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/others/musl_a
	export MUSLVER=${VERSION:-$(echo musl-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/others/musl_a/musl-$MUSLVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/l/gmp
	export GMPVER=${VERSION:-$(echo gmp-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/l/gmp/gmp-$GMPVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/l/isl
	export ISLVER=${VERSION:-$(echo isl-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
	cp -v $RDIR/l/isl/isl-$ISLVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/grep
	export GREPVER=${VERSION:-$(echo grep-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/grep/grep-$GREPVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/gzip
	export GZIPVER=${VERSION:-$(echo gzip-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/gzip/gzip-$GZIPVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/k
	export LINUXVER=${VERSION:-$(echo linux-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/k/linux-$LINUXVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/lzip
	export LZIPVER=${VERSION:-$(echo lzip-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/lzip/lzip-$LZIPVER.tar.lz $SRCDIR || exit 1
    cd $RDIR/d/m4
	export M4VER=${VERSION:-$(echo m4-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/d/m4/m4-$M4VER.tar.xz $SRCDIR || exit 1
	cp -v $RDIR/d/m4/m4.glibc228.diff.gz $SRCDIR || exit 1
    cd $RDIR/d/automake
	export AUTOMAKEVER=${VERSION:-$(echo automake-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/d/automake/automake-$AUTOMAKEVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/d/make
	export MAKEVER=${VERSION:-$(echo make-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/d/make/make-$MAKEVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/l/libffi
	export LIBFFIVER=${VERSION:-$(echo libffi-*.tar.?z | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
    cp -v $RDIR/l/libffi/libffi-$LIBFFIVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/l/libmpc
	export LIBMPCVER=${VERSION:-$(echo libpmc-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/l/libmpc/mpc-$LIBMPCVER.tar.lz $SRCDIR || exit 1
    cd $RDIR/l/mpfr
	export MPFRVER=${VERSION:-$(echo mpfr-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/l/mpfr/mpfr-$MPFRVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/l/ncurses
	PKGNAM=ncurses && export NCURVER=${VERSION:-$(echo $PKGNAM-*.tar.?z | cut -f 2- -d - | cut -f 1,2 -d .)}
	cp -v $RDIR/l/ncurses/ncurses-$NCURVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/patch
	export PATCHVER=${VERSION:-$(echo patch-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/patch/patch-$PATCHVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/d/python3
	export PYTHVER=${VERSION:-$(echo Python-*.tar.xz | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
    cp -v $RDIR/d/python3/Python-$PYTHVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/d/perl
	export PERLVER=${VERSION:-$(echo perl-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/d/perl/perl-$PERLVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/others
#	export PCROSSVER=${VERSION:-$(echo perl-cross-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
	export PCROSSVER="1.3.5"
    cp -v $RDIR/others/perl-cross-$PCROSSVER.tar.?z $SRCDIR || exit 1
    cd $RDIR/a/sed
	export SEDVER=${VERSION:-$(echo sed-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/sed/sed-$SEDVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/tar
	export TARVER=${VERSION:-$(echo tar-*.tar.xz | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/tar/tar-$TARVER.tar.xz $SRCDIR || exit 1
    cp -v $RDIR/a/tar/tar-1.13.tar.gz $SRCDIR || exit 1
    cp -v $RDIR/a/tar/tar-1.13.bzip2.diff.gz $SRCDIR || exit 1
    cd $RDIR/ap/texinfo
	export TEXINFOVER=${VERSION:-$(echo texinfo-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/ap/texinfo/texinfo-$TEXINFOVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/util-linux
	export UTILVER=${VERSION:-$(echo util-linux*.tar.xz | cut -d - -f 3  | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/util-linux/util-linux-$UTILVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/a/which
	export WHICHVER=${VERSION:-$(echo which-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/which/which-$WHICHVER.tar.gz $SRCDIR || exit 1
    cd $RDIR/a/xz
	export XZVER=${VERSION:-$(echo xz-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/a/xz/xz-$XZVER.tar.xz $SRCDIR || exit 1
    cd $RDIR/l/zstd
	export ZSTDVER=${VERSION:-$(echo zstd-*.tar.?z | cut -d - -f 2 | rev | cut -f 3- -d . | rev)}
    cp -v $RDIR/l/zstd/zstd-$ZSTDVER.tar.?z $SRCDIR || exit 1
	# copy patch from void to build mlfs
	cp -v $RDIR/others/musl_patch_void/*.patch $SRCDIR || exit 1
	if [[ "$ada_enable" = "yes" ]]
	then
		case $(uname -m) in
			i686 ) 
				if [ -f $RDIR/others/gnat-gpl-2014-x86-linux-bin.tar.gz ]; then
					cd $RDIR/others
					cp -v $RDIR/others/gnat-gpl-2014-x86-linux-bin.tar.gz $SRCDIR || exit 1
				fi
				[ $? != 0 ] && exit 1 ;;
			x86_64 )
				if [ -f $RDIR/others/gnat-gpl-2017-x86_64-linux-bin.tar.gz ]; then
					cd $RDIR/others 
					cp -v $RDIR/others/gnat-gpl-2017-x86_64-linux-bin.tar.gz $SRCDIR || exit 1
				fi
				[ $? != 0 ] && exit 1 ;;
		esac
	elif [[ "$ada_enable" = "no" ]]
	then
		echo
	fi
}

test_to_go () {
#*****************************
    echo
    echo "Are you to go on ok?"
    echo
    PS3="Your choice:"
    select build in go-on quit
    do
        if [[ "$build" = "go-on" ]]
        then
            break
        else [[ "$build" = "quit" ]]
            echo -e "$RED" "You have decided to quit. Goodbye." "$NORMAL" && exit 1
        fi
    done
    echo -e "$GREEN" "You choose to continue the process of building 'tools' for MLFS." "$NORMAL" 
}

linux_headers_cross_build () {
#*****************************
	tar xvf linux-$LINUXVER.tar.xz && cd linux-$LINUXVER
	make mrproper || exit 1
	make ARCH=${MLFS_ARCH} headers_check || exit 1
	make ARCH=${MLFS_ARCH} headers || exit 1
	mkdir -pv /cross-tools/${MLFS_TARGET}/include || exit 1
	cp -rv usr/include/* /cross-tools/${MLFS_TARGET}/include || exit1
	rm -v /cross-tools/${MLFS_TARGET}/include/Makefile || exit 1
	cd ..
	rm -rf linux-$LINUXVER
}

binutils_cross_build () {
#*****************************
    tar xvf binutils-$BINUVER.tar.?z && cd binutils-$BINUVER

    mkdir -v build && cd build

	../configure \
	   --prefix=/cross-tools \
	   --target=${MLFS_TARGET} \
	   --with-sysroot=/cross-tools/${MLFS_TARGET} \
	   --disable-nls \
	   --disable-multilib \
	   --disable-werror \
	   --enable-deterministic-archives \
	   --disable-compressed-debug-sections || exit 1

	make configure-host || exit 1

    make || exit 1

    make install || exit 1
    cd ../..
    rm -rf binutils-$BINUVER
}

gcc_cross_build () {
#*****************************
    tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

    tar xvf ../mpfr-$MPFRVER.tar.xz
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.lz
    mv -v mpc-$LIBMPCVER mpc

	mkdir -v build && cd build

	../configure \
		  --prefix=/cross-tools \
		  --build=${MLFS_HOST} \
		  --host=${MLFS_HOST} \
		  --target=${MLFS_TARGET} \
		  --with-sysroot=/cross-tools/${MLFS_TARGET} \
	      --disable-nls \
	      --with-newlib \
		  --disable-libitm \
	      --disable-libvtv \
		  --disable-libssp \
	      --disable-shared \
		  --disable-libgomp \
		  --without-headers \
		  --disable-threads \
		  --disable-multilib \
		  --disable-libatomic \
		  --disable-libstdcxx \
		  --enable-languages=c,c++ \
		  --disable-libquadmath \
		  --disable-libsanitizer \
		  --with-arch=${MLFS_CPU} \
		  --disable-decimal-float \
		  --enable-clocale=generic || exit 1

	make all-gcc all-target-libgcc || exit 1
	make install-gcc install-target-libgcc || exit 1
	cd ../..
	rm -rf gcc-$SRCVER
}

generate_ld_musl_path () {
#*****************************
mkdir -v /cross-tools/etc
cat > /cross-tools/etc/ld-musl-$ARCH.path << "EOF"
/cross-tools/lib
/tools/lib
EOF
}

musl_cross_build () {
#*****************************
	tar xf musl-$MUSLVER.tar.?z && cd musl-$MUSLVER

	export PATH=

	case $(uname -m) in
	  x86_64) export ARCH="x86_64" 
          ;;
	  i686)   export ARCH="i386"
         ;;
	esac

	PATH=/bin:/usr/bin:/cross-tools/bin:/tools/bin

	./configure CROSS_COMPILE=${MLFS_TARGET}- \
	  --prefix=/ \
	  --target=${MLFS_TARGET} || exit 1

	make || exit 1
	DESTDIR=/cross-tools make install || exit 1
	# Add missing directory and link
	mkdir -v /cross-tools/usr
	ln -sv ../include  /cross-tools/usr/include

	# Create link for ldd:
	ln -sv ../lib/ld-musl-$ARCH.so.1 /cross-tools/bin/ldd
	# Create config for dynamic library loading:
	generate_ld_musl_path

	unset ARCH
	cd ..
	rm -rf musl-$MUSLVER
}

gcc_final_build () {
#*****************************
    tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

    tar xvf ../mpfr-$MPFRVER.tar.?z
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.?z
    mv -v mpc-$LIBMPCVER mpc

	# Apply patches [from void-linux]
	patch -Np0 -i ../gcc-9.1.0-void/ada-shared.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-cxxflags-passing.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-musl-execinfo.patch
	patch -Np0 -i ../gcc-9.1.0-void/libgcc-musl-ldbl128-config.patch
	patch -Np0 -i ../gcc-9.1.0-void/musl-ada.patch
	patch -Np0 -i ../gcc-9.1.0-void/no-stack_chk_fail_local.patch
	patch -Np0 -i ../gcc-9.1.0-void/non-nullness.patch
	patch -Np1 -i ../gcc-10.1.0-Enable-CET-in-cross-compiler-if-possible.patch

	case $(uname -m) in
	  x86_64)
		sed -e '/m64=/s/lib64/lib/' \
		    -i.orig gcc/config/i386/t-linux64
	 ;;
	esac

	mkdir -v build && cd build

	PATH=/bin:/usr/bin:/cross-tools/bin:/tools/bin

	AR=ar LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
	../configure \
		--prefix=/cross-tools \
		--build=${MLFS_HOST} \
		--host=${MLFS_HOST} \
		--target=${MLFS_TARGET} \
		--disable-multilib \
		--with-sysroot=/cross-tools \
		--disable-nls \
		--enable-shared \
		--enable-languages=c,c++ \
		--enable-threads=posix \
		--enable-clocale=generic \
		--enable-libstdcxx-time \
		--enable-fully-dynamic-string \
		--disable-symvers \
		--disable-libsanitizer \
		--disable-lto-plugin \
		--disable-libssp || exit 1

	make AS_FOR_TARGET="${MLFS_TARGET}-as" LD_FOR_TARGET="${MLFS_TARGET}-ld" || exit 1
	make install || exit 1
	cd ../..
	rm -rf gcc-$SRCVER
}

file_cross_build () {
#*****************************
    tar xvf file-$FILEVER.tar.?z && cd file-$FILEVER

	PATH=/bin:/usr/bin:/cross-tools/bin:/tools/bin

	./configure --prefix=/cross-tools --disable-libseccomp || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf file-$FILEVER
}

create_dynamic_linker_config () {
#*****************************
# Create dynamic linker config
mkdir -pv /tools/etc &&
cat > /tools/etc/ld-musl-${barch}.path << "EOF"
/tools/lib
EOF
}

musl_chain_build () {
#*****************************
	tar xvf musl-$MUSLVER.tar.?z && cd musl-$MUSLVER

	./configure CROSS_COMPILE=${MLFS_TARGET}- \
	  --prefix=/ \
	  --target=${MLFS_TARGET}

	make || exit 1
	make DESTDIR=/tools install || exit 1

	case $(uname -m) in
  		x86_64) 
		   rm -v  /tools/lib/ld-musl-x86_64.so.1
           ln -sv libc.so /tools/lib/ld-musl-x86_64.so.1
           export barch=$(uname -m) ;;

  		i686)    
		   rm -v  /tools/lib/ld-musl-i386.so.1
           ln -sv libc.so /tools/lib/ld-musl-i386.so.1
	   	   export barch=i386 ;;
	esac

	create_dynamic_linker_config

	cd ..
	rm -rf musl-$MUSLVER
}

adjust_cross_toolchain () {
#*****************************
	# Dump current cross-gcc specs 
	export SPECFILE=`dirname $(${MLFS_TARGET}-gcc -print-libgcc-file-name)`/specs
	${MLFS_TARGET}-gcc -dumpspecs > specs

	# Modify dumped specs file for every instance of:
	# /lib/ld-musl-$ARCH.so.1 to /tools/lib/ld-musl-$ARCH.so.1
	case $(uname -m) in
	  x86_64)  
		sed -i 's/\/lib\/ld-musl-x86_64.so.1/\/tools\/lib\/ld-musl-x86_64.so.1/g' specs
       # check with
       grep "/tools/lib/ld-musl-x86_64.so.1" specs  --color=auto ;;

	  i686)    
		sed -i 's/\/lib\/ld-musl-i386.so.1/\/tools\/lib\/ld-musl-i386.so.1/g' specs
       # check with
       grep "/tools/lib/ld-musl-i386.so.1" specs  --color=auto ;;
	esac

	# Install modified specs to the cross toolchain
	mv -v specs $SPECFILE
	unset SPECFILE
}

tool_chain_binutils_build () {
#*****************************
	# Link directories so libraries can be found in both lib & lib64
	case $(uname -m) in
		x86_64) cd /tools && ln -sv lib /tools/lib64 ;;
	esac
	
	cd $MLFS/sources	
		
    tar xvf binutils-$BINUVER.tar.?z && cd binutils-$BINUVER

#    mkdir -v build && cd build

	# Set the environment to cross-compile with cross-tools
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	PATH=/cross-tools/bin:tools/bin:/bin:/usr/bin

	./configure --prefix=/tools            \
		         --with-lib-path=/tools/lib \
		         --build=${MLFS_HOST}       \
		         --host=${MLFS_TARGET}      \
		         --target=${MLFS_TARGET}    \
		         --disable-nls              \
		         --disable-werror           \
		         --with-sysroot || exit 1

    make || exit 1

    make install || exit 1
	# Build and install linker that will be used later after adjusting toolchain
	make -C ld LIB_PATH=/usr/lib:/lib 
	cp -v ld/ld-new /tools/bin

    cd ..
    rm -rf binutils-$BINUVER
}

tools_chain_gcc_build () {
#*****************************
    tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

    tar xvf ../mpfr-$MPFRVER.tar.xz
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.lz
    mv -v mpc-$LIBMPCVER mpc

	# Apply patches [from void-linux] .. works for version 10.2.0
	patch -Np0 -i ../gcc-9.1.0-void/ada-shared.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-cxxflags-passing.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-musl-execinfo.patch
	patch -Np0 -i ../gcc-9.1.0-void/libgcc-musl-ldbl128-config.patch
	patch -Np0 -i ../gcc-9.1.0-void/musl-ada.patch
	patch -Np0 -i ../gcc-9.1.0-void/no-stack_chk_fail_local.patch
	patch -Np0 -i ../gcc-9.1.0-void/non-nullness.patch

	# Set the environment for cross-compiling if not done already.
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	# Re-create internal header
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($MLFS_TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h

	# change the location of GCC's default dynamic linker to use the one installed in /tools
	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
	  cp -uv $file{,.orig}
	  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
		  -e 's@/usr@/tools@g' $file.orig > $file
	  echo '
	#undef STANDARD_STARTFILE_PREFIX_1
	#undef STANDARD_STARTFILE_PREFIX_2
	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
	  touch $file.orig
	done

	mkdir -v build && cd build

	CFLAGS='-g0 -O0' \
	CXXFLAGS='-g0 -O0' \
	../configure                                       \
		--target=${MLFS_TARGET}                        \
		--build=${MLFS_HOST}                           \
		--host=${MLFS_TARGET}                          \
		--prefix=/tools                                \
		--with-local-prefix=/tools                     \
		--with-native-system-header-dir=/tools/include \
		--enable-languages=c,c++                       \
		--disable-libstdcxx-pch                        \
		--disable-multilib                             \
		--disable-bootstrap                            \
		--disable-libgomp                              \
		--disable-libquadmath                          \
		--disable-libssp                               \
		--disable-libvtv                               \
		--disable-symvers                              \
		--disable-libitm                               \
		--disable-libsanitizer || exit 1

	PATH=/bin:/usr/bin:/cross-tools/bin:/tools/bin make

	make install
	ln -sv gcc /tools/bin/cc 
	GCC_INCLUDEDIR=`dirname $(${MLFS_TARGET}-gcc -print-libgcc-file-name)`/include &&
	find ${GCC_INCLUDEDIR}/* -maxdepth 0 -xtype d -exec rm -rvf '{}' \; &&
	rm -vf `grep -l "DO NOT EDIT THIS FILE" ${GCC_INCLUDEDIR}/*` &&
	unset GCC_INCLUDEDIR
	cd ../..
	rm -rf gcc-$SRCVER
}

tool_chain_linux_headers_build () {
#*****************************
	tar xvf linux-$LINUXVER.tar.xz && cd linux-$LINUXVER
	make mrproper || exit 1
	ARCH=${MLFS_ARCH} make headers || exit 1
	find usr/include \( -name .install -o -name ..install.cmd \) -delete || exit 1
	cp -rv usr/include/* /tools/include || exit 1
	rm -v /tools/include/Makefile || exit 1
	cd ..
	rm -rf linux-$LINUXVER
	mkdir $MLFS/tools/etc && touch $MLFS/tools/etc/tools_version
	echo linux-$LINUXVER >> $MLFS/tools/etc/tools_version
}

tool_chain_adjust_cross_toolchain () {
#*****************************
	# Dump gcc specs
	SPECFILE=`dirname $(${MLFS_TARGET}-gcc -print-libgcc-file-name)`/specs &&
	${MLFS_TARGET}-gcc -dumpspecs > tempspecfile

	# Modify dumped tempspecfile file for every instance of:
	# /lib/ld-musl-$ARCH.so.1 to /tools/lib/ld-musl-$ARCH.so.1 

	case $(uname -m) in
	   i686) 
		    sed -i 's/\/lib\/ld-musl-i386.so.1/\/tools\/lib\/ld-musl-i386.so.1/g' tempspecfile
		    grep "/tools/lib/ld-musl-i386.so.1" tempspecfile  --color=auto ;;
	   x86_64) 
		    sed -i 's/\/lib\/ld-musl-x86_64.so.1/\/tools\/lib\/ld-musl-x86_64.so.1/g' tempspecfile
			grep "/tools/lib/ld-musl-x86_64.so.1" tempspecfile --color=auto ;;
	esac

	mv -vf tempspecfile $SPECFILE &&
	unset SPECFILE

	GCC_INCLUDEDIR=`dirname $(${MLFS_TARGET}-gcc -print-libgcc-file-name)`/include &&
	find ${GCC_INCLUDEDIR}/* -maxdepth 0 -xtype d -exec rm -rvf '{}' \; &&
	rm -vf `grep -l "DO NOT EDIT THIS FILE" ${GCC_INCLUDEDIR}/*` &&
	unset GCC_INCLUDEDIR
}

libstdc_build () {
#*****************************
	tar xf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

	# Apply patches [from void-linux] .. works for version 10.2.0
	patch -Np0 -i ../gcc-9.1.0-void/ada-shared.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-cxxflags-passing.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-musl-execinfo.patch
	patch -Np0 -i ../gcc-9.1.0-void/libgcc-musl-ldbl128-config.patch
	patch -Np0 -i ../gcc-9.1.0-void/musl-ada.patch
	patch -Np0 -i ../gcc-9.1.0-void/no-stack_chk_fail_local.patch
	patch -Np0 -i ../gcc-9.1.0-void/non-nullness.patch

	# Set up environment for cross-compile
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	mkdir -v build && cd build

	../libstdc++-v3/configure           \
		--target=${MLFS_TARGET}         \
		--build=${MLFS_HOST}            \
		--host=${MLFS_TARGET}           \
		--prefix=/tools                 \
		--disable-multilib              \
		--disable-nls                   \
		--disable-libstdcxx-threads     \
		--disable-libstdcxx-pch         \
		--with-gxx-include-dir=/tools/${MLFS_TARGET}/include/c++/$GCCVER || exit 1

	make || exit 1
	make install || exit 1
	cd ../..
	rm -rf gcc-$SRCVER
}

m4_build () {
#*****************************
    tar xvf m4-$M4VER.tar.xz && cd m4-$M4VER

	zcat ../m4.glibc228.diff.gz | patch -Esp1 --verbose || exit 1

	# Set the environment to cross-compile with cross-tools
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	PATH=/cross-tools/bin:tools/bin:/bin:/usr/bin

	./configure --prefix=/tools \
		        --build=${MLFS_HOST} \
		        --host=${MLFS_TARGET} || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf m4-$M4VER
	echo m4-$M4VER >> $MLFS/tools/etc/tools_version
}

ncurses_build () {
#*****************************
    tar xvf ncurses-$NCURVER.tar.lz && cd ncurses-$NCURVER
	 
	 sed -i s/mawk// configure
    
	./configure \
		--prefix=/tools \
		--build=${MLFS_HOST} \
		--host=${MLFS_TARGET} \
		--with-shared   \
		--without-debug \
		--without-ada   \
		--enable-widec  \
		--enable-overwrite || exit 1

    make || exit 1
    make install || exit 1
    ln -s libncursesw.so /mnt/mlfs/tools/lib/libncurses.so
	cd ..
    rm -rf ncurses-$NCURVER
	echo ncurses-$NCURVER >> $MLFS/tools/etc/tools_version
}

generate_bash_config () {
#*****************************
cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF
}

bash_build () {
#*****************************
    tar xvf bash-$BASHVER.tar.?z && cd bash-$BASHVER || exit 1

	# fix a race condition if using multiple cores: 
	sed -i  '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' Makefile.in

	# Cross Compiling the configure script 
	# does not does not determine the correct 
	# values for the following, Set the values 
	# manually: 
	generate_bash_config

	./configure --build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
		--prefix=/tools \
        --without-bash-malloc \
        --cache-file=config.cache || exit 1

    make || exit 1
    make install || exit 1
    ln -sv bash /tools/bin/sh || exit 1
    cd ..
    rm -rf bash-$BASHVER
	echo bash-$BASHVER >> $MLFS/tools/etc/tools_version
}

binutils_build_sp2 () {
#*****************************
	tar xvf binutils-$BINUVER.tar.?z && cd binutils-$BINUVER

	mkdir -v build && cd build

	CC=$MLFS_TGT-gcc                \
	AR=$MLFS_TGT-ar                 \
	RANLIB=$MLFS_TGT-ranlib         \
	../configure                   \
		--prefix=/tools            \
		--disable-nls              \
		--disable-werror           \
		--with-lib-path=/tools/lib \
		--with-sysroot || exit 1

	make || exit 1
	make install || exit 1

	make -C ld clean || exit 1
	make -C ld LIB_PATH=/usr/lib:/lib || exit 1
	cp -v ld/ld-new /tools/bin || exit 1

	cd ../..
	rm -rf binutils-$BINUVER
	echo binutils-$BINUVER >> $MLFS/tools/etc/tools_version
}

gmp_build () {
#*****************************
    tar xvf gmp-$GMPVER.tar.?z && cd gmp-$GMPVER

    ./configure --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf gmp-$GMPVER
	echo gmp-$GMPVER >> $MLFS/tools/etc/tools_version
}

isl_build () {
#*****************************
    tar xvf isl-$ISLVER.tar.xz && cd isl-$ISLVER

    ./configure --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf isl-$ISLVER
	echo isl-$ISLVER >> $MLFS/tools/etc/tools_version
}

gcc_build_sp2 () {
#*****************************
tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($MLFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

    tar xvf ../mpfr-$MPFRVER.tar.xz
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.lz
    mv -v mpc-$LIBMPCVER mpc

# fix a problem introduced by glibc-2.31
sed -e '1161 s|^|//|' -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

   mkdir -v build && cd build

	CC=$MLFS_TGT-gcc                                    \
	CXX=$MLFS_TGT-g++                                   \
	AR=$MLFS_TGT-ar                                     \
	RANLIB=$MLFS_TGT-ranlib                             \
	../configure                                       \
		 --prefix=/tools                                \
		 --with-local-prefix=/tools                     \
		 --with-native-system-header-dir=/tools/include \
		 --enable-languages=c,c++                       \
		 --disable-libstdcxx-pch                        \
		 --disable-multilib                             \
		 --disable-bootstrap                            \
		 --disable-libgompp || exit 1

    make || exit 1
    make install || exit 1
    ln -sv gcc /tools/bin/cc || exit 1
    cd ../..
    rm -rf gcc-$SRCVER
	 echo gcc-$SRCVER >> $MLFS/tools/etc/tools_version
}

tools_chain_gcc_build () {
#*****************************
    tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

    tar xvf ../mpfr-$MPFRVER.tar.xz
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.lz
    mv -v mpc-$LIBMPCVER mpc

	# Apply patches [from void-linux] .. works for version 10.2.0
	patch -Np0 -i ../gcc-9.1.0-void/ada-shared.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-cxxflags-passing.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-musl-execinfo.patch
	patch -Np0 -i ../gcc-9.1.0-void/libgcc-musl-ldbl128-config.patch
	patch -Np0 -i ../gcc-9.1.0-void/musl-ada.patch
	patch -Np0 -i ../gcc-9.1.0-void/no-stack_chk_fail_local.patch
	patch -Np0 -i ../gcc-9.1.0-void/non-nullness.patch

	# Set the environment for cross-compiling if not done already.
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	# Re-create internal header
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($MLFS_TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h

	# change the location of GCC's default dynamic linker to use the one installed in /tools
	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
	  cp -uv $file{,.orig}
	  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
		  -e 's@/usr@/tools@g' $file.orig > $file
	  echo '
	#undef STANDARD_STARTFILE_PREFIX_1
	#undef STANDARD_STARTFILE_PREFIX_2
	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
	  touch $file.orig
	done

	mkdir -v build && cd build

	CFLAGS='-g0 -O0' \
	CXXFLAGS='-g0 -O0' \
	../configure                                       \
		--target=${MLFS_TARGET}                        \
		--build=${MLFS_HOST}                           \
		--host=${MLFS_TARGET}                          \
		--prefix=/tools                                \
		--with-local-prefix=/tools                     \
		--with-native-system-header-dir=/tools/include \
		--enable-languages=c,c++                       \
		--disable-libstdcxx-pch                        \
		--disable-multilib                             \
		--disable-bootstrap                            \
		--disable-libgomp                              \
		--disable-libquadmath                          \
		--disable-libssp                               \
		--disable-libvtv                               \
		--disable-symvers                              \
		--disable-libitm                               \
		--disable-libsanitizer || exit 1

	PATH=/bin:/usr/bin:/cross-tools/bin:/tools/bin make

	make install
	ln -sv gcc /tools/bin/cc 
	GCC_INCLUDEDIR=`dirname $(${MLFS_TARGET}-gcc -print-libgcc-file-name)`/include &&
	find ${GCC_INCLUDEDIR}/* -maxdepth 0 -xtype d -exec rm -rvf '{}' \; &&
	rm -vf `grep -l "DO NOT EDIT THIS FILE" ${GCC_INCLUDEDIR}/*` &&
	unset GCC_INCLUDEDIR
	cd ../..
	rm -rf gcc-$SRCVER
}


gnat_build_sp2 () {
#*****************************
	cd $MLFS/sources
    tar xvf gcc-$SRCVER.tar.?z && cd gcc-$SRCVER

    tar xvf ../mpfr-$MPFRVER.tar.xz
    mv -v mpfr-$MPFRVER mpfr
    tar xvf ../gmp-$GMPVER.tar.?z
    mv -v gmp-$GMPVER gmp
    tar xvf ../mpc-$LIBMPCVER.tar.lz
    mv -v mpc-$LIBMPCVER mpc

	# Apply patches [from void-linux] .. works for version 10.2.0
	patch -Np0 -i ../gcc-9.1.0-void/ada-shared.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-cxxflags-passing.patch
	patch -Np0 -i ../gcc-9.1.0-void/fix-musl-execinfo.patch
	patch -Np0 -i ../gcc-9.1.0-void/libgcc-musl-ldbl128-config.patch
	patch -Np0 -i ../gcc-9.1.0-void/musl-ada.patch
	patch -Np0 -i ../gcc-9.1.0-void/no-stack_chk_fail_local.patch
	patch -Np0 -i ../gcc-9.1.0-void/non-nullness.patch

	# Re-create internal header
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($MLFS_TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h

	# change the location of GCC's default dynamic linker to use the one installed in /tools
#	for file in gcc/config/{linux,i386/linux{,64}}.h
#	do
#	  cp -uv $file{,.orig}
#	  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
#		  -e 's@/usr@/tools@g' $file.orig > $file
#	  echo '
#	#undef STANDARD_STARTFILE_PREFIX_1
#	#undef STANDARD_STARTFILE_PREFIX_2
#	#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#	#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
#	  touch $file.orig
#	done

	mkdir -v build && cd build

	CFLAGS='-g0 -O0' \
	CXXFLAGS='-g0 -O0' \
	../configure 				\
		--target=${MLFS_TARGET} \
		--build=${MLFS_HOST}    \
		--host=${MLFS_TARGET}   \
		--disable-multilib 		\
		--enable-bootstrap 		\
		--enable-languages=ada || exit 1

    make || exit 1
	make bootstrap || exit 1
	make -C gcc gnatlib || exit 1
	make -C gcc gnattools || exit 1
    make install || exit 1
	export PATH=$PATH_HOLD
    cd ../..
	rm -rf gnat-gpl*
	rm -rf /tools/opt/gnat
	rm -rf /tools/tmp
}

bison_build () {
#*****************************
    tar xvf bison-$BISONVER.tar.?z && cd bison-$BISONVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf bison-$BISONVER
	echo bison-$BISONVER >> $MLFS/tools/etc/tools_version
}

bzip2_build () {
#*****************************
    tar xvf bzip2-$BZIP2VER.tar.lz && cd bzip2-$BZIP2VER

	# Set the environment to cross-compile with cross-tools
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	PATH=/cross-tools/bin:tools/bin:/bin:/usr/bin

	# Fix the Makefiles for  ensures installation of symbolic 
	# links are relative and the man pages are installed into 
	# the correct location:
	cp Makefile{,.orig}
	sed -e "/^all:/s/ test//" Makefile.orig > Makefile
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

	# Prepare source
	make -f Makefile-libbz2_so CC="${CC}" AR="${AR}" RANLIB="${RANLIB}"
	make clean
    make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" || exit 1
    make PREFIX=/tools install || exit 1
	cp -v bzip2-shared /tools/bin/bzip2
	cp -av libbz2.so* /tools/lib
	ln -sv libbz2.so.1.0 /tools/lib/libbz2.so
    cd ..
    rm -rf bzip2-$BZIP2VER
	echo bzip2-$BZIP2VER >> $MLFS/tools/etc/tools_version
}

generate_coreutils_config () {
#*****************************
cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=no
ac_cv_func_syncfs=no
gl_cv_func_working_mkstemp=yes
gl_cv_func_working_acl_get_file=yes
EOF
}

coreutils_build () {
#*****************************
    tar xvf coreutils-$COREVER.tar.xz && cd coreutils-$COREVER

	# Apply patch
#	patch -Np0 -i ../0001-ls-restore-8.31-behavior-on-removed-directories.patch
	cat ../0001-ls-restore-8.31-behavior-on-removed-directories.patch | patch -Esp0 --verbose || exit 1

	# Re-create configure script
	autoreconf -vif

	# Cross Compiling the configure script 
	# does not does not determine the correct 
	# values for the following, Set the values 
	# manually:
	generate_coreutils_config

	# Suppress a test which on some machines can loop forever:
	sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools \
        --enable-install-program=hostname \
        --cache-file=config.cache || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf coreutils-$COREVER
	echo coreutils-$COREVER >> $MLFS/tools/etc/tools_version
}

diffutils_build () {
#*****************************
    tar xvf diffutils-$DIFFVER.tar.xz && cd diffutils-$DIFFVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf diffutils-$DIFFVER
	echo diffutils-$DIFFVER >> $MLFS/tools/etc/tools_version
}

file_build () {
#*****************************
    tar xvf file-$FILEVER.tar.?z && cd file-$FILEVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf file-$FILEVER
	echo file-$FILEVER >> $MLFS/tools/etc/tools_version
}

findutils_build () {
#*****************************
    tar xvf findutils-$FINDVER.tar.lz && cd findutils-$FINDVER

	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
	sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
	echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf findutils-$FINDVER
	echo findutils-$FINDVER >> $MLFS/tools/etc/tools_version
}

gawk_build () {
#*****************************
    tar xvf gawk-$GAWKVER.tar.lz && cd gawk-$GAWKVER
	
	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf gawk-$GAWKVER
	echo gawk-$GAWKVER >> $MLFS/tools/etc/tools_version
}

gettext_build () {
#*****************************
    tar xvf gettext-$GETTVER.tar.lz && cd gettext-$GETTVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools \
        --disable-shared || exit 1

    make || exit 1

    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /tools/bin || exit 1
    cd ..
    rm -rf gettext-$GETTVER
	echo gettext-$GETTVER >> $MLFS/tools/etc/tools_version
}

grep_build () {
#*****************************
    tar xvf grep-$GREPVER.tar.xz && cd grep-$GREPVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf grep-$GREPVER
	echo grep-$GREPVER >> $MLFS/tools/etc/tools_version
}

gzip_build () {
#*****************************
    tar xvf gzip-$GZIPVER.tar.xz && cd gzip-$GZIPVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf gzip-$GZIPVER
	echo gzip-$GZIPVER >> $MLFS/tools/etc/tools_version
}

automake_build () {
#*****************************
    tar xvf automake-$AUTOMAKEVER.tar.xz && cd automake-$AUTOMAKEVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1

	# links necessary to build "make" with patches

	ln -sf /tools/bin/aclocal /tools/bin/aclocal-1.15
	ln -sf /tools/bin/automake /tools/bin/automake-1.15
    cd ..
    rm -rf automake-$AUTOMAKEVER
	echo automake-$AUTOMAKEVER >> $MLFS/tools/etc/tools_version
}

make_build () {
#*****************************
    tar xvf make-$MAKEVER.tar.?z && cd make-$MAKEVER

	./configure \
		--build=${MLFS_HOST}  \
        --host=${MLFS_TARGET} \
        --prefix=/tools       \
        --without-guile || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf make-$MAKEVER
	echo make-$MAKEVER >> $MLFS/tools/etc/tools_version
}

patch_build () {
#*****************************
    tar xvf patch-$PATCHVER.tar.xz && cd patch-$PATCHVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1 

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf patch-$PATCHVER
	echo patch-$PATCHVER >> $MLFS/tools/etc/tools_version
}

perl_build () {
#*****************************
    tar xvf perl-$PERLVER.tar.?z && cd perl-$PERLVER
	cd .. &&
	tar xf perl-cross-$PCROSSVER.tar.?z
	cd perl-$PERLVER &&
	mv -v ../perl-cross-$PCROSSVER/* ./
	mv -v ../perl-cross-$PCROSSVER/utils/* utils/

	# Apply patch from Alpine to fix locale.c errors
	# in programs such as rxvt-unicode
	cat ../musl-locale.patch | patch -Esp1 --verbose || exit 1

	# Set the environment to cross-compile with cross-tools
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

#	./configure \
#		--prefix=/tools \
#        --target=${MLFS_TARGET} || exit 1
    sh Configure -des -Dprefix=/tools -Dtarget=${MLFS_TARGET} -Dlibs=-lm -Uloclibpth -Ulocincpth || exit 1
    make || exit 1
    cp -v perl cpan/podlators/scripts/pod2man /tools/bin || exit 1
    mkdir -pv /tools/lib/perl5/$PERLVER || exit 1
    cp -Rv lib/* /tools/lib/perl5/$PERLVER || exit 1
    cd ..
    rm -rf perl-$PERLVER
    rm -rf perl-cross-$PCROSSVER
	echo perl-$PERLVER >> $MLFS/tools/etc/tools_version
	echo perl-cross-$PCROSSVER >> $MLFS/tools/etc/tools_version
}

libffi_build () {
#*****************************
    tar xvf libffi-$LIBFFIVER.tar.?z && cd libffi-$LIBFFIVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools \
		--disable-static  \
		--with-gcc-arch=native || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf libffi-$LIBFFIVER
	echo libffi-$LIBFFIVER >> $MLFS/tools/etc/tools_version
}


generate_python_config () {
#*****************************
cat > config.cache << EOF
ac_cv_file__dev_ptmx=no
ac_cv_file__dev_ptc=no
EOF
}

python_build () {
#*****************************
    tar xvf Python-$PYTHVER.tar.?z && cd Python-$PYTHVER

	# Set the environment to cross-compile with cross-tools
	export CC="${MLFS_TARGET}-gcc"
	export CXX="${MLFS_TARGET}-g++"
	export AR="${MLFS_TARGET}-ar"
	export AS="${MLFS_TARGET}-as"
	export RANLIB="${MLFS_TARGET}-ranlib"
	export LD="${MLFS_TARGET}-ld"
	export STRIP="${MLFS_TARGET}-strip"

	PATH=/tools/bin:/cross-tools/bin:/bin:/usr/bin

    sed -i '/def add_multiarch_paths/a \        return' setup.py || exit 1

	generate_python_config

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --with-prefix=/tools \
        --disable-ipv6  \
		--enable-shared \
		--without-ensurepip \
        --cache-file=config.cache || exit 1

    make || exit 1
    make DESTDIR=/tools install || exit 1
    cd ..
    rm -rf Python-$PYTHVER
	echo Python-$PYTHVER >> $MLFS/tools/etc/tools_version
}

sed_build () {
#*****************************
    tar xvf sed-$SEDVER.tar.xz && cd sed-$SEDVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf sed-$SEDVER
	echo sed-$SEDVER >> $MLFS/tools/etc/tools_version
}

tar_build () {
#*****************************
    tar xvf tar-$TARVER.tar.xz && cd tar-$TARVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf tar-$TARVER
	echo tar-$TARVER >> $MLFS/tools/etc/tools_version
}

texinfo_build () {
#*****************************
    tar xvf texinfo-$TEXINFOVER.tar.xz && cd texinfo-$TEXINFOVER

	zcat ../texinfo.fix.unescaped.left.brace.diff.gz | patch -p1 --verbose || exit 1

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools \
		--disable-perl-xs || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf texinfo-$TEXINFOVER
	echo texinfo-$TEXINFOVER >> $MLFS/tools/etc/tools_version
}

util_linux_build () {
#*****************************
    tar xvf util-linux-$UTILVER.tar.xz && cd util-linux-$UTILVER

	./configure \
		--build=${MLFS_HOST} 		   \
        --host=${MLFS_TARGET} 		   \
        --prefix=/tools 			   \
    	--without-python 			   \
    	--without-ncurses              \
    	--disable-makeinstall-chown    \
    	--without-systemdsystemunitdir \
    	PKG_CONFIG="" || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf util-linux-$UTILVER
	echo util-linux-$UTILVER >> $MLFS/tools/etc/tools_version
}

xz_build () {
#*****************************
    tar xvf xz-$XZVER.tar.xz && cd xz-$XZVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf xz-$XZVER
	echo xz-$XZVER >> $MLFS/tools/etc/tools_version
}

lzip_build () {
#*****************************
    tar xvf lzip-$LZIPVER.tar.lz && cd lzip-$LZIPVER

    ./configure --prefix=/tools || exit 1

	# run sed to fix it
	sed -i 's/CXX = g++/CXX = ${MLFS_TARGET}-g++/g' Makefile

    make || exit 1
    make install || exit 1
    cd ..
    rm -rf lzip-$LZIPVER
	echo lzip-$LZIPVER >> $MLFS/tools/etc/tools_version
}

tar_slack_build () {
#*****************************
    tar xvf tar-1.13.tar.gz && cd tar-1.13

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
		--disable-nls || exit 1 

	zcat ../tar-1.13.bzip2.diff.gz | patch -p1 || exit 1

    make || exit 1
    cd src && mv -v tar tar-1.13
    cp -v tar-1.13 /tools/bin/tar-1.13 || exit 1
    cd ../..
    rm -rf tar-1.13
	echo tar-1.13 >> $MLFS/tools/etc/tools_version
}

which_build () {
#*****************************
    tar xvf which-$WHICHVER.tar.gz && cd which-$WHICHVER

	./configure \
		--build=${MLFS_HOST} \
        --host=${MLFS_TARGET} \
        --prefix=/tools || exit 1

    make || exit 1
    cp -v which /tools/bin/which || exit 1
    cd ..
    rm -rf which-$WHICHVER
    echo which-$WHICHVER >> $MLFS/tools/etc/tools_version
}

zstd_build () {
#*****************************
    tar xvf zstd-$ZSTDVER.tar.?z && cd zstd-$ZSTDVER

	make || exit 1
	make check || exit 1
    make prefix=/tools install || exit 1
    cd ..
    rm -rf zstd-$ZSTDVER
    echo zstd-$ZSTDVER >> $MLFS/tools/etc/tools_version
}

strip_libs () {
#*****************************
    strip --strip-debug /tools/lib/*
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/*
    rm -rf /tools/{,share}/{info,man,doc}
	find /tools/{lib,libexec} -name \*.la -delete
}

clean_sources () {
#*****************************
echo "clean sources packages"
rm *.xz *.lz *.bz2 *.gz *.patch
}

echo_end () {
#*****************************
    echo "The building of tools for mlfs is finished."
    echo
	if [[ "$ada_enable" = "yes" ]]
		then
		echo "Now you can 'exit' from 'mlfs environment"
		echo
		echo "Just type:"
		echo
		echo -e "$GREEN" "exit" "$NORMAL"
		echo
		echo "then type:"
		echo
		echo -e "$GREEN" "cd gcc*/build && make install 2>&1 | tee > /dev/null" "$NORMAL"
		echo
		echo "then type:"
		echo
		echo -e "$GREEN" "cd ../.. && rm -rf gcc*" "$NORMAL"
		echo
	elif [[ "$ada_enable" = "no" ]]
		then
			echo "Just type:"
			echo
			echo -e "$GREEN" "exit" "$NORMAL"
	fi
    echo "then type:"
	echo
	echo -e "$GREEN" "./chroot_mlfs.sh" "$NORMAL"
    echo

}

#*****************************
# core script
#*****************************
echo_begin
# ada_choice
copy_src
test_to_go
cd $SRCDIR
linux_headers_cross_build
binutils_cross_build
gcc_cross_build
musl_cross_build
gcc_final_build
file_cross_build
musl_chain_build
adjust_cross_toolchain
tool_chain_binutils_build
tools_chain_gcc_build
tool_chain_linux_headers_build
tool_chain_adjust_cross_toolchain
libstdc_build
m4_build
ncurses_build
bash_build
bison_build
bzip2_build
coreutils_build
diffutils_build
file_build
findutils_build
gawk_build
gettext_build
grep_build
gzip_build
automake_build
make_build
patch_build
perl_build
libffi_build
python_build
sed_build
tar_build
texinfo_build
xz_build
lzip_build
tar_slack_build
which_build
util_linux_build
zstd_build
# binutils_build_sp2
# gmp_build
# isl_build
# gcc_build_sp2

#*****************************
if [[ "$ada_enable" = "yes" ]]
then
	case $(uname -m) in
		x86_64)
			tar xf gnat-gpl-2017-x86_64-linux-bin.tar.gz
			if [ $? != 0 ]; then
				echo
				echo "Tar extraction of gnat-gpl-2017-x86_64-linux-bin failed."
				echo
			exit 1
			fi
			# Now prepare the environment
			cd gnat-gpl-2017-x86_64-linux-bin

			[ $? != 0 ] && exit 1 ;;
		i686)
			tar xf gnat-gpl-2014-x86-linux-bin.tar.gz
			if [ $? != 0 ]; then
				echo
				echo "Tar extraction of gnat-gpl-2014-x86-linux-bin failed."
				echo
			exit 1
			fi
			# Now prepare the environment
			cd gnat-gpl-2014-x86-linux-bin
			[ $? != 0 ] && exit 1 ;;
	esac
	mkdir -pv /tools/opt/gnat
	make ins-all prefix=/tools/opt/gnat
	PATH_HOLD=$PATH && export PATH=/tools/opt/gnat/bin:$PATH_HOLD
	echo $PATH
	find /tools/opt/gnat -name ld -exec mv -v {} {}.old \;
	find /tools/opt/gnat -name ld -exec as -v {} {}.old \;
	gnat_build_sp2
elif [[ "$ada_enable" = "no" ]]
 then
	echo
	break
fi
#*****************************
strip_libs
clean_sources
echo_end
exit 0
