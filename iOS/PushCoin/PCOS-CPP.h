//
//  PCOS.h
//  PushCoin
//
//  Created by Gilbert Cheung on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
#ifndef PushCoin_PCOS_h
#define PushCoin_PCOS_h

#include <string>
#include <vector>

typedef unsigned offset_t;

struct invalid_format_exception : public std::exception
{ };

// Data Container
typedef struct 
{
    char * data;
    offset_t offset;
    size_t length;
    
    char * bytes() const
    { return data + offset; }
    
    void consume(size_t len) 
    {
        length -= len;
        offset += len;
    }
    
} 
raw_data_t;

// PCOS Types
struct ByteType   { };
struct CharType   { };
struct BoolType   { };
struct Int16Type  { };
struct Int32Type  { };
struct Int64Type  { };
struct DoubleType { };

// Type Traits
template <typename>
struct field_type_trait;

template<> struct field_type_trait<ByteType>
{
    typedef char c_type;
    static const size_t size = 1; 
};

template<> struct field_type_trait<CharType>
{
    typedef char c_type;
    static const size_t size = 1; 
};

template<> struct field_type_trait<BoolType>
{
    typedef bool c_type;
    static const size_t size = 1; 
};

template<> struct field_type_trait<Int16Type>
{
    typedef int16_t c_type;
    static const size_t size = 2;
};

template<> struct field_type_trait<Int32Type>
{
    typedef int32_t c_type;
    static const size_t size = 4;
};
template<> struct field_type_trait<Int64Type>
{
    typedef int64_t c_type;
    static const size_t size = 8;
};

template<> struct field_type_trait<DoubleType>
{
    typedef double c_type;
    static const size_t size = 8;
};

// PCOS Encoding
struct base_type
{
    virtual size_t encode(raw_data_t data) const = 0;
    virtual size_t decode(raw_data_t data) = 0;
};

template<typename field_type>
struct basic_type : public base_type
{
    typedef field_type value_type;
    typename field_type_trait<field_type>::c_type val;
    static const size_t size = field_type_trait<field_type>::size; 
    
    size_t encode(raw_data_t data) const
    {
        if (data.length < size)
            throw invalid_format_exception();
        
        memcpy(data.bytes(), &val, size);
        return size;
    }
    
    size_t decode(raw_data_t data)
    {
        if (data.length < size)
            throw invalid_format_exception();
        
        memcpy(&val, data.bytes(), size);
        return size;
    }
    
    typename field_type_trait<field_type>::c_type get() const
    { return val; }
    
    void set(typename field_type_trait<field_type>::c_type v)
    { val = v; }
};

struct base_array_type : base_type
{
    virtual size_t encode_size(raw_data_t data) const = 0;
    virtual size_t decode_size(raw_data_t data) = 0;
    virtual void check_size(size_t c) const = 0;
};

template<typename block_type>
struct array_type : base_array_type
{
    typedef std::vector<block_type> vector_type;
    vector_type val;
    
    size_t encode(raw_data_t data) const
    {
        size_t total = 0;
        size_t len = 0;
        size_t count = this->encode_size(data);
        
        for (int i = 0; i < count; ++i)
        {
            total += (len = val[i].encode(data));
            data.consume(len);
        }
        return total;
    }
    
    size_t decode(raw_data_t data) 
    {
        size_t total = 0;
        size_t len = 0;
        size_t count = this->decode_size(data);
        
        for (int i = 0; i < count; ++i)
        {
            total += (len = val[i].decode(data));
            data.consume(len);
        }
        return total;
    }

 };

template<typename field_type>
struct basic_array_type : base_array_type
{
    typedef std::vector<typename field_type_trait<field_type>::c_type> vector_type;
    vector_type val;
    
    void do_set(typename field_type_trait<field_type>::c_type const * v, size_t c)
    {
        this->check_size(c);
        val.resize(c);
        memcpy(&val[0], v, c * field_type_trait<field_type>::size);
    }
    
    typename field_type_trait<field_type>::c_type * do_get(size_t & c)
    {
        c = val.size();
        return &val[0];
    }
    
    void set(typename field_type_trait<field_type>::c_type const * v, size_t count) 
    { do_set(v, count); }
    
    typename field_type_trait<field_type>::c_type * get(size_t & count) 
    { return do_get(count); }
    
    size_t encode(raw_data_t data) const
    {
        size_t count = this->encode_size(data);
        memcpy(data.bytes(), &val[0], count * field_type_trait<field_type>::size);
        
        return count * field_type_trait<field_type>::size;
    }
    
    size_t decode(raw_data_t data) 
    {
        size_t count = this->decode_size(data);
        memcpy(&val[0], data.bytes(), count * field_type_trait<field_type>::size);
        
        return count * field_type_trait<field_type>::size;
    }
};


template<typename field_type>
struct array_type<basic_type<field_type> > : basic_array_type<field_type>
{
};


template<>
struct array_type<basic_type<CharType> > : basic_array_type<CharType>
{
    void set(std::string const & str)
    {
        do_set(str.c_str(), str.length());
    }
    std::string get()
    {
        size_t count;
        char * str = do_get(count);
        return std::string(str, count);
    }
};


template<typename block_type, size_t count>
struct fixed_array_type : public array_type<block_type>
{
    void check_size(size_t c) const
    {
        if (c != count)
        throw invalid_format_exception();
    }
    
    size_t encode_size(raw_data_t data) const
    {
        return count;
    }
    
    size_t decode_size(raw_data_t data)
    {
        return count;
    }
};

template<typename block_type, typename index_type = Int16Type>
struct var_array_type : public array_type<block_type>
{
    typedef typename field_type_trait<index_type>::c_type index_t;
    using array_type<block_type>::val;
    
    void check_size(size_t) const
    { }
    
    size_t encode_size(raw_data_t data) const
    {
        index_t count = val.size();
        
        memcpy(data.bytes(), &count, field_type_trait<index_type>::size);
        
        return count;
    }
    
    size_t decode_size(raw_data_t data)
    {
        index_t count = 0;
        
        memcpy(&count, data.bytes(), field_type_trait<index_type>::size);
        val.resize(count);
        
        return count;
    }
};

template<typename field_type>
struct short_array_type  : var_array_type<field_type, ByteType>
{};

template<typename field_type>
struct long_array_type  : var_array_type<field_type, Int16Type>
{};

template<typename field_type>
struct optional_basic_type : short_array_type<field_type>
{
    void set(typename field_type_trait<field_type>::c_type v) 
    { set(&v, 1); }
    
    bool is_set()
    {
        size_t count;
        get(count);
        return count != 0;
    }
    
    typename field_type_trait<field_type>::c_type get() 
    { 
        size_t count;
        typename field_type_trait<field_type>::c_type * ptr = get(count);
        if (count != 0)
            return *ptr;
        
        throw invalid_format_exception();
    }
};

struct block : public base_type
{
    typedef std::vector<base_type *> blocks_t;
    blocks_t blocks;
    
    void append_block(base_type & blk)
    {
        blocks.push_back(&blk);
    }
    
    size_t encode(raw_data_t data) const
    {
        size_t len = 0;
        size_t total = 0;
        
        for(blocks_t::const_iterator it = blocks.begin();
            it != blocks.end(); ++it)
        {
            total += (len = (*it)->encode(data));
            data.consume(len);
        }
        return total;
    }
    
    size_t decode(raw_data_t data)
    {
        size_t len = 0;
        size_t total = 0;
        
        for(blocks_t::iterator it = blocks.begin();
            it != blocks.end(); ++it)
        {
            total += (len = (*it)->decode(data));
            data.consume(len);
        }
        return total;
    }
};


// PCOS Message Definitions

struct header_block : public block
{
    fixed_array_type<basic_type<CharType>, 4> magic;
    fixed_array_type<basic_type<CharType>, 2> msg_id;
    basic_type<Int16Type> msg_len;
    
    header_block()
    {
        append_block(magic);
        append_block(msg_id);
        append_block(msg_len);
    }
};

struct block_meta_block : public block
{
    fixed_array_type<basic_type<CharType>, 2> block_id;
    basic_type<Int16Type> block_len;
    
    block_meta_block()
    {
        append_block(block_id);
        append_block(block_len);
    }
};

struct block_enum_block : public block
{
    long_array_type<block_meta_block> blocks;
    
    block_enum_block()
    {
        append_block(blocks);
    }
};

struct message : public block
{
    header_block hdr;
    block_enum_block block_enums;
    
    message()
    {
        append_block(hdr);
        append_block(block_enums);
    }
};

        
struct PingMessage : public message
{

    
    
    
};


int main()
 {
 
 PingMessage ping;
 char * test = (char *) calloc(1000, 1);
 raw_data_t raw = {test, 0, 1000};
 
 ping.hdr.magic.set("PCOS");
 ping.hdr.msg_id.set("pi");
 ping.hdr.msg_len.set(100);
 
 size_t len =  ping.encode(raw);
 
 PingMessage ping2;
 size_t len2 = ping.decode(raw);
 std::string magic = ping.hdr.magic.get();
 std::string msg_id = ping.hdr.msg_id.get();
 short msg_len = ping.hdr.msg_len.get();
 
 NSLog(@"%@", [NSString stringWithCString:magic.c_str() encoding
 :NSASCIIStringEncoding]);
 
 }


#endif
*/