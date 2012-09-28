#include "helpers.h"

static VALUE mTextDisplay, mTextDisplayHelpers;

static VALUE cHelpers_split_escaped_chars(VALUE self, VALUE str)
{
  rb_encoding *enc = rb_enc_get(str);
  VALUE res = rb_ary_new();
  char *ptr = RSTRING_PTR(str);
  char *bef = ptr;
  char *cur = ptr;
  while (*cur) {
    if (*cur != '\e') { cur++; continue; }
    if (cur[1] != '[') { cur++; continue; }

    VALUE head = rb_enc_str_new(bef, (cur - bef), enc);
    VALUE chars_enum = rb_funcall(head, rb_intern("each_char"), 0);
    VALUE chars = rb_funcall(chars_enum, rb_intern("to_a"), 0);
    rb_ary_concat(res, chars);

    char *e;
    e = cur + 2;
    while (*e) {
      if ( (*e >= '0' && *e <= '9') ||
	   *e == ';' )
	{
	  e++;
	  continue;
	}
      e++;
      break;
    }

    VALUE escaped_char = rb_enc_str_new(cur, (e - cur), enc);
    rb_ary_push(res, escaped_char);
    cur = e;
    bef = cur;
  }

  VALUE tail = rb_enc_str_new(bef, strlen(bef), enc);
  VALUE chars_enum = rb_funcall(tail, rb_intern("each_char"), 0);
  VALUE chars = rb_funcall(chars_enum, rb_intern("to_a"), 0);
  rb_ary_concat(res, chars);

  return res;
}

static VALUE cHelpers_split_escape_sequence(VALUE self, VALUE str)
{
  char *ptr = RSTRING_PTR(str);
  long len = RSTRING_LEN(str);
  if (len < 3) return rb_ary_new();
  if (ptr[0] != '\e') return rb_ary_new();
  if (ptr[1] != '[') return rb_ary_new();
  if (ptr[2] == 'm') return rb_ary_new3(1, rb_str_new2("0"));

  ptr += 2;
  char cur;
  char buf[256];
  long i = 0;
  VALUE res = rb_ary_new();
  while (cur = *ptr++) {
    
    if ( cur >= '0' && cur <= '9')
      {
        buf[i] = cur;
        i++;
      }
    else if (cur == ';')
      {
        rb_ary_push(res, rb_str_new(buf, i));
        i = 0;
      }
    else if (cur == 'm')
      {
	rb_ary_push(res, rb_str_new(buf, i));
	return res;
      }
    else
      {
	return res;
      }
  }
}

void Init_helpers()
{
  mTextDisplay = rb_define_module("TextDisplay");
  mTextDisplayHelpers = rb_define_module_under(mTextDisplay, "Helpers");
  rb_define_method(mTextDisplayHelpers, "split_escaped_chars",
                   cHelpers_split_escaped_chars, 1);
  rb_define_method(mTextDisplayHelpers, "split_escape_sequence",
		   cHelpers_split_escape_sequence, 1);
}
