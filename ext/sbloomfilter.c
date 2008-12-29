/*
 *   sbloomfilter.c - simple Bloom Filter
 *   (c) Tatsuya Mori <valdzone@gmail.com>
 */

#include "ruby.h"
#include "crc32.h"

static VALUE cBloomFilter;

struct BloomFilter {
    int m; /* # of bits in a bloom filter */
    int k; /* # of hash functions */
    int s; /* seed of hash functions */
    int num_set; /* # of set bits */
    unsigned char *ptr; /* bits data */
};

void bits_free(struct BloomFilter *bf) {
    ruby_xfree(bf->ptr);
}

void bit_set(struct BloomFilter *bf, int index) {
    int byte_offset = index / 8;
    int bit_offset = index % 8;
    unsigned char c = bf->ptr[byte_offset];

    c |= (1 << bit_offset);
    bf->ptr[byte_offset] = c;
}

int bit_check(struct BloomFilter *bf, int index) {
    int byte_offset = index / 8;
    int bit_offset = index % 8;
    unsigned char c = bf->ptr[byte_offset];

    return c & (1 << bit_offset);
}

int bit_get(struct BloomFilter *bf, int index) {
    int byte_offset = index / 8;
    int bit_offset = index % 8;
    unsigned char c = bf->ptr[byte_offset];

    return (c & (1 << bit_offset)) ? 1 : 0;
}

static VALUE bf_s_new(int argc, VALUE *argv, VALUE self) {
    struct BloomFilter *bf;
    VALUE arg1, arg2, arg3, obj;
    int m, k, s, bytes;

    obj = Data_Make_Struct(self, struct BloomFilter, NULL, bits_free, bf);

    if (argc == 3) {
        arg1 = argv[0];
        arg2 = argv[1];
        arg3 = argv[2];
    } else if (argc == 2) {
        arg1 = argv[0];
        arg2 = argv[1];
        arg3 = INT2FIX(0);
    } else if (argc == 1) {
        arg1 = argv[0];
        arg2 = INT2FIX(4);
        arg3 = INT2FIX(0);
    } else { /* default = Fugou approach :-) */
        arg1 = INT2FIX(100000000);
        arg2 = INT2FIX(4);
        arg3 = INT2FIX(0);
    }

    m = FIX2INT(arg1);
    k = FIX2INT(arg2);
    s = FIX2INT(arg3);

    if (m < 1)
        rb_raise(rb_eArgError, "array size");
    if (k < 1)
        rb_raise(rb_eArgError, "hash length");
    if (s < 0)
        rb_raise(rb_eArgError, "random seed");

    bf->m = m;
    bf->k = k;
    bf->s = s;
    bf->num_set = 0;

    bytes = (m + 7) / 8;
    bf->ptr = ALLOC_N(unsigned char, bytes);

    /* initialize the bits with zeros */
    memset(bf->ptr, 0, bytes);
    rb_iv_set(obj, "@hash_value", rb_hash_new());

    return obj;
}

static VALUE bf_m(VALUE self) {
    struct BloomFilter *bf;
    Data_Get_Struct(self, struct BloomFilter, bf);
    return INT2FIX(bf->m);
}

static VALUE bf_k(VALUE self) {
    struct BloomFilter *bf;
    Data_Get_Struct(self, struct BloomFilter, bf);
    return INT2FIX(bf->k);
}

static VALUE bf_num_set(VALUE self) {
    struct BloomFilter *bf;
    Data_Get_Struct(self, struct BloomFilter, bf);
    return INT2FIX(bf->num_set);
}

static VALUE bf_insert(VALUE self, VALUE key) {
    int index, seed;
    int i, len, m, k, s;
    char *ckey;

    struct BloomFilter *bf;
    Data_Get_Struct(self, struct BloomFilter, bf);

    Check_Type(key, T_STRING);
    ckey = STR2CSTR(key);
    len = (int) (RSTRING(key)->len); /* length of the string in bytes */

    m = bf->m;
    k = bf->k;
    s = bf->s;

    for (i = 0; i <= k - 1; i++) {
        /* seeds for hash functions */
        seed = i + s;

        /* hash */
        index = (int) (crc32((unsigned int) (seed), ckey, len) % (unsigned int) (m));

        /*  set a bit at the index */
        bit_set(bf, index);
    }

    bf->num_set += 1;
    return Qnil;
}

static VALUE bf_include(VALUE self, VALUE key) {
    int index, seed;
    int i, len, m, k, s;
    char *ckey;

    struct BloomFilter *bf;
    Data_Get_Struct(self, struct BloomFilter, bf);

    Check_Type(key, T_STRING);
    ckey = STR2CSTR(key);
    len = (int) (RSTRING(key)->len); /* length of the string in bytes */

    m = bf->m;
    k = bf->k;
    s = bf->s;

    for (i = 0; i <= k - 1; i++) {
        /* seeds for hash functions */
        seed = i + s;

        /* hash */
        index = (int) (crc32((unsigned int) (seed), ckey, len) % (unsigned int) (m));

        /* check the bit at the index */
        if (!bit_check(bf, index))
            return Qfalse; /* i.e., it is a new entry ; escape the loop */
    }

    return Qtrue;
}

static VALUE bf_to_s(VALUE self) {
    struct BloomFilter *bf;
    unsigned char *ptr;
    int i;
    VALUE str;

    Data_Get_Struct(self, struct BloomFilter, bf);
    str = rb_str_new(0, bf->m);

    ptr = (unsigned char *) RSTRING(str)->ptr;
    for (i = 0; i < bf->m; i++)
        *ptr++ = bit_get(bf, i) ? '1' : '0';

    return str;
}

void Init_sbloomfilter(void) {
    cBloomFilter = rb_define_class("BloomFilter", rb_cObject);
    rb_define_singleton_method(cBloomFilter, "new", bf_s_new, -1);
    rb_define_method(cBloomFilter, "m", bf_m, 0);
    rb_define_method(cBloomFilter, "k", bf_k, 0);
    rb_define_method(cBloomFilter, "num_set", bf_num_set, 0);
    rb_define_method(cBloomFilter, "insert", bf_insert, 1);
    rb_define_method(cBloomFilter, "include?", bf_include, 1);
    rb_define_method(cBloomFilter, "to_s", bf_to_s, 0);

    /* functions that have not been implemented, yet */

    //  rb_define_method(cBloomFilter, "clear", bf_clear, 0);
    //  rb_define_method(cBloomFilter, "&", bf_and, 1);
    //  rb_define_method(cBloomFilter, "|", bf_or, 1);
    //  rb_define_method(cBloomFilter, "<=>", bf_cmp, 1);
}
